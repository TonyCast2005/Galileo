extends Control

@onready var label_pregunta = $TextoPregunta
@onready var respuesta = $Respuesta
@onready var mensaje = $Mensaje
@onready var validar = $validar
@onready var titulo = $NombreLección
@onready var boton_pista = $Pista
@onready var http = $HTTPRequest

var escena_pista: PackedScene = preload("res://escenas/Pistas/Pistas_Contenedor.tscn")

const DB_URL: String = "https://galileo-af640-default-rtdb.firebaseio.com/preguntas_abiertas.json"

var preguntas: Dictionary = {}
var pregunta_actual: String = ""
var indice_pregunta: int = 0
var pistas_actuales: Array[String] = []

# ======================================================
# READY
# ======================================================
func _ready() -> void:
	titulo.text = "Preguntas abiertas - Arduino nivel novato"

	validar.pressed.connect(_on_validar_pressed)
	boton_pista.pressed.connect(_mostrar_pista)

	await cargar_preguntas()

	if preguntas.size() > 0:
		mostrar_pregunta()
	else:
		mensaje.text = "No se pudieron cargar las preguntas."

# ===============================
# SISTEMA DE ERRORES
# ===============================
var errores: int = 0
var errores_maximos: int = 3   # Puedes ajustar libremente

func fallar_demasiado() -> void:
	Globals.desbloquear = false
	get_tree().change_scene_to_file("res://escenas/Tipos_preguntas/RepiteLeccion.tscn")

# ======================================================
# Cargar preguntas desde Firebase
# ======================================================
func cargar_preguntas() -> void:
	var err: int = http.request(DB_URL)
	if err != OK:
		push_error("Error al conectar con Firebase")
		return

	var response: Array = await http.request_completed
	var body: PackedByteArray = response[3]

	var texto: String = body.get_string_from_utf8()
	var data: Variant = JSON.parse_string(texto)

	if typeof(data) == TYPE_DICTIONARY:
		for key: String in data.keys():
			var item: Dictionary = data[key]
			if typeof(item) == TYPE_DICTIONARY:
				var pregunta: String = item.get("pregunta", "")
				if pregunta != "":
					preguntas[pregunta] = item
	else:
		push_error("Formato incorrecto en Firebase")


# ======================================================
# Mostrar pregunta
# ======================================================
func mostrar_pregunta() -> void:
	var claves: Array = preguntas.keys()

	if indice_pregunta >= claves.size():
		label_pregunta.text = ""
		mensaje.text = "¡Has terminado todas las preguntas!"
		get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")
		validar.disabled = true
		boton_pista.visible = false
		return

	pregunta_actual = String(claves[indice_pregunta])
	var data: Dictionary = preguntas[pregunta_actual]

	label_pregunta.text = pregunta_actual
	respuesta.text = ""
	mensaje.text = ""

	# Pistas
	if data.has("pistas") and typeof(data["pistas"]) == TYPE_ARRAY:
		var arr: Array = data["pistas"]
		pistas_actuales = []
		for p in arr:
			pistas_actuales.append(String(p))
	else:
		pistas_actuales = []

	boton_pista.visible = pistas_actuales.size() > 0


# ======================================================
# Normalizar texto
# ======================================================
func normalizar_texto(texto: String) -> String:
	var t: String = texto.strip_edges().to_lower()

	var acentos := {
		"á":"a","é":"e","í":"i","ó":"o","ú":"u","ñ":"n"
	}

	for a in acentos.keys():
		t = t.replace(a, acentos[a])

	var signos: Array[String] = [",",".",";","?", "¿", "¡", "!", ":"]
	for s: String in signos:
		t = t.replace(s, "")

	return t.strip_edges()


# ======================================================
# Levenshtein
# ======================================================
func levenshtein(a: String, b: String) -> int:
	var m: int = a.length()
	var n: int = b.length()

	var matrix: Array = []

	for i in range(m + 1):
		matrix.append([])
		for j in range(n + 1):
			matrix[i].append(0)

	for i in range(m + 1):
		matrix[i][0] = i
	for j in range(n + 1):
		matrix[0][j] = j

	for i in range(1, m + 1):
		for j in range(1, n + 1):
			var cost: int = 0 if a[i-1] == b[j-1] else 1
			matrix[i][j] = min(
				matrix[i-1][j] + 1,
				matrix[i][j-1] + 1,
				matrix[i-1][j-1] + cost
			)

	return matrix[m][n]


func similitud_ortografica(a: String, b: String) -> float:
	if a.is_empty() or b.is_empty():
		return 0.0
	var dist: int = levenshtein(a, b)
	var max_len: int = max(a.length(), b.length())
	return 1.0 - float(dist) / float(max_len)


func porcentaje_palabras_clave(resp: String, claves: Array, sinonimos: Dictionary) -> float:
	if claves.is_empty():
		return 0.0

	var total: int = claves.size()
	var ok: int = 0

	for p in claves:
		var palabra: String = String(p)
		if palabra in resp:
			ok += 1
		elif sinonimos.has(palabra):
			var arr: Array = sinonimos[palabra]
			for s in arr:
				if String(s) in resp:
					ok += 1
					break

	return float(ok) / float(total)


# ======================================================
# Evaluar respuesta
# ======================================================
func evaluar_respuesta(pregunta: String, resp_user: String) -> Dictionary:
	var data: Dictionary = preguntas[pregunta]

	var modelo: String = normalizar_texto(data["respuesta_modelo"])
	var resp: String = normalizar_texto(resp_user)

	var palabras: Array = data.get("palabras_clave", [])
	var sinonimos: Dictionary = data.get("sinonimos", {})

	var pct: float = porcentaje_palabras_clave(resp, palabras, sinonimos)
	var sim: float = similitud_ortografica(resp, modelo)

	if sim >= 0.80:
		return {"resultado":"correcta","mensaje":"¡Excelente!"}

	if pct >= 0.80 and sim >= 0.60:
		return {"resultado":"correcta","mensaje":"Muy bien!"}

	if pct >= 0.33 and sim >= 0.60:
		return {"resultado":"parcial","mensaje":"Vas bien, falta un poco."}

	return {
		"resultado":"incorrecta",
		"mensaje":"Incorrecto.\nRespuesta correcta:\n" + data["respuesta_modelo"]
		
	}

# ======================================================
# Validar
# ======================================================
func _on_validar_pressed() -> void:
	if pregunta_actual == "":
		return

	var r: Dictionary = evaluar_respuesta(pregunta_actual, respuesta.text)

	mensaje.text = r["mensaje"]
	if r["resultado"] == "incorrecta":
		errores += 1
		
		if errores >= errores_maximos:
			fallar_demasiado()
			return  # <-- IMPORTANTE: No continúa a la siguiente pregunta
		
		return  # solo falló, puede seguir intentando

	# =====================
	# RESPUESTA CORRECTA
	# =====================
	indice_pregunta += 1
	await get_tree().create_timer(1.4).timeout
	mostrar_pregunta()


# ======================================================
# MOSTRAR PISTA
# ======================================================
func _mostrar_pista() -> void:
	if pistas_actuales.is_empty():
		return

	var texto: String = pistas_actuales.pop_front()

	var ventana: Control = escena_pista.instantiate()
	add_child(ventana)
	ventana.set_pista(texto)
