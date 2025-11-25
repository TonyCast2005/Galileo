extends Control

@onready var label_pregunta = $TextoPregunta
@onready var respuesta = $Respuesta
@onready var mensaje = $Mensaje
@onready var validar = $validar
@onready var titulo = $NombreLección

const DB_URL = "https://galileo-af640-default-rtdb.firebaseio.com/preguntas_abiertas.json"

var preguntas = {}
var pregunta_actual = ""
var indice_pregunta = 0

func _ready():
	titulo.text = "Preguntas abiertas - Arduino nivel novato"

	await cargar_preguntas()

	if preguntas.size() > 0:
		mostrar_pregunta()
	else:
		mensaje.text = "No se pudieron cargar las preguntas."

	validar.pressed.connect(_on_validar_pressed)

# -----------------------------------------------------
# Cargar preguntas desde Firebase
# -----------------------------------------------------
func cargar_preguntas() -> void:
	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(DB_URL)
	if err != OK:
		push_error("Error al conectar con Firebase")
		return

	var response = await http.request_completed
	var body = response[3]
	var data = JSON.parse_string(body.get_string_from_utf8())

	if typeof(data) == TYPE_DICTIONARY:
		for k in data.keys():
			var item = data[k]
			preguntas[item["pregunta"]] = item
	else:
		push_error("Formato incorrecto en Firebase")

	http.queue_free()

# -----------------------------------------------------
# Mostrar pregunta actual
# -----------------------------------------------------
func mostrar_pregunta():
	var claves = preguntas.keys()

	if indice_pregunta >= claves.size():
		mensaje.text = "¡Has terminado todas las preguntas!"
		label_pregunta.text = ""
		validar.disabled = true
		return

	pregunta_actual = claves[indice_pregunta]
	label_pregunta.text = pregunta_actual
	respuesta.text = ""
	mensaje.text = ""


# -----------------------------------------------------
# Normalizar
# -----------------------------------------------------
func normalizar_texto(texto: String) -> String:
	texto = texto.strip_edges().to_lower()

	var acentos = {
		"á":"a","é":"e","í":"i","ó":"o","ú":"u",
		"ñ":"n"
	}
	for a in acentos.keys():
		texto = texto.replace(a, acentos[a])

	var signos = [",", ".", ";", ":", "?", "!", "¿", "¡"]
	for s in signos:
		texto = texto.replace(s, "")

	return texto.strip_edges()

func levenshtein(a: String, b: String) -> int:
	var m = a.length()
	var n = b.length()
	var matrix = []

	for i in range(m+1):
		matrix.append([])
		for j in range(n+1):
			matrix[i].append(0)

	for i in range(m+1): matrix[i][0] = i
	for j in range(n+1): matrix[0][j] = j

	for i in range(1,m+1):
		for j in range(1,n+1):
			var cost = 0 if a[i-1] == b[j-1] else 1
			matrix[i][j] = min(
				matrix[i-1][j] + 1,
				matrix[i][j-1] + 1,
				matrix[i-1][j-1] + cost
			)

	return matrix[m][n]

func similitud_ortografica(a: String, b: String) -> float:
	if a.length() == 0 or b.length() == 0:
		return 0.0
	var dist = levenshtein(a, b)
	var max_len = max(a.length(), b.length())
	return 1.0 - float(dist) / max_len

func porcentaje_palabras_clave(respuesta: String, palabras_clave: Array, sinonimos: Dictionary) -> float:
	if palabras_clave.size() == 0:
		return 0.0

	var total = palabras_clave.size()
	var ok = 0

	for palabra in palabras_clave:
		if palabra in respuesta:
			ok += 1
		elif sinonimos.has(palabra):
			for s in sinonimos[palabra]:
				if s in respuesta:
					ok += 1
					break

	return float(ok)/total

# -----------------------------------------------------
# Evaluar respuesta
# -----------------------------------------------------
func evaluar_respuesta(pregunta: String, respuesta_usuario: String) -> Dictionary:
	var data = preguntas[pregunta]

	var modelo = normalizar_texto(data["respuesta_modelo"])
	var palabras = data.get("palabras_clave", [])
	var sinonimos = data.get("sinonimos", {})

	var resp = normalizar_texto(respuesta_usuario)

	var pct = porcentaje_palabras_clave(resp, palabras, sinonimos)
	var sim = similitud_ortografica(resp, modelo)

	if sim >= 0.80:
		return {"resultado":"correcta","mensaje":"¡Excelente!"}

	if pct >= 0.80 and sim >= 0.60:
		return {"resultado":"correcta","mensaje":"Muy bien!"}

	if pct >= 0.33 and sim >= 0.60:
		return {"resultado":"parcial","mensaje":"Vas bien, pero puedes mejorar."}

	return {
		"resultado":"incorrecta",
		"mensaje":"Incorrecto.\nRespuesta correcta:\n" + data["respuesta_modelo"]
	}

# -----------------------------------------------------
# Botón validar
# -----------------------------------------------------
func _on_validar_pressed():
	if pregunta_actual == "":
		mensaje.text = "No hay pregunta actual."
		return

	var r = evaluar_respuesta(pregunta_actual, respuesta.text)
	mensaje.text = r["mensaje"]

	if r["resultado"] != "incorrecta":
		indice_pregunta += 1
		await get_tree().create_timer(1.5).timeout
		mostrar_pregunta()

func _on_pista_pressed() -> void:
	pass # Replace with function body.
