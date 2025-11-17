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


# -----------------------------------------------------
# READY
# -----------------------------------------------------
func _ready():
	titulo.text = "Preguntas abiertas - Lección 1"

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

	if typeof(data) == TYPE_ARRAY:
		for item in data:
			if item != null:
				preguntas[item["pregunta"]] = item

	elif typeof(data) == TYPE_DICTIONARY:
		for k in data.keys():
			var item = data[k]
			preguntas[item["pregunta"]] = item

	else:
		push_error("Error al parsear preguntas desde Firebase")

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
# Normalizar texto
# -----------------------------------------------------
func normalizar_texto(texto: String) -> String:
	texto = texto.strip_edges().to_lower()

	var acentos = {
		"á":"a","é":"e","í":"i","ó":"o","ú":"u",
		"ä":"a","ë":"e","ï":"i","ö":"o","ü":"u",
		"ñ":"n"
	}
	for a in acentos.keys():
		texto = texto.replace(a, acentos[a])

	var signos = [",", ".", ";", ":", "?", "!", "¿", "¡", "(", ")", "[", "]"]
	for s in signos:
		texto = texto.replace(s, "")

	var articulos = [" el ", " la ", " los ", " las ", " un ", " una ", " unos ", " unas "]
	for a in articulos:
		texto = texto.replace(a, " ")

	while "  " in texto:
		texto = texto.replace("  ", " ")

	return texto.strip_edges()


# -----------------------------------------------------
# Distancia de Levenshtein
# -----------------------------------------------------
func levenshtein(a: String, b: String) -> int:
	var m = a.length()
	var n = b.length()

	var matrix = []
	for i in range(m + 1):
		matrix.append([])
		for j in range(n + 1):
			matrix[i].append(0)

	for i in range(m + 1): matrix[i][0] = i
	for j in range(n + 1): matrix[0][j] = j

	for i in range(1, m + 1):
		for j in range(1, n + 1):
			var costo = 0 if a[i - 1] == b[j - 1] else 1
			matrix[i][j] = min(
				matrix[i - 1][j] + 1,
				matrix[i][j - 1] + 1,
				matrix[i - 1][j - 1] + costo
			)

	return matrix[m][n]


# -----------------------------------------------------
# Similitud ortográfica
# -----------------------------------------------------
func similitud_ortografica(a: String, b: String) -> float:
	if a.length() == 0 or b.length() == 0:
		return 0.0

	var dist = levenshtein(a, b)
	var max_len = max(a.length(), b.length())
	return 1.0 - float(dist) / float(max_len)


# -----------------------------------------------------
# Porcentaje de palabras clave encontradas
# -----------------------------------------------------
func porcentaje_palabras_clave(respuesta: String, palabras_clave: Array, sinonimos: Dictionary) -> float:
	if palabras_clave.size() == 0:
		return 0.0

	var total = palabras_clave.size()
	var encontradas = 0

	for palabra in palabras_clave:
		if palabra in respuesta:
			encontradas += 1
		elif sinonimos.has(palabra):
			for s in sinonimos[palabra]:
				if s in respuesta:
					encontradas += 1
					break

	return float(encontradas) / float(total)


# -----------------------------------------------------
# Evaluar respuesta del usuario
# -----------------------------------------------------
func evaluar_respuesta(pregunta: String, respuesta_usuario: String) -> Dictionary:
	if not preguntas.has(pregunta):
		return {"error": "Pregunta no encontrada"}

	var data = preguntas[pregunta]

	var modelo = normalizar_texto(data["respuesta_modelo"])
	var palabras_clave = data["palabras_clave"]
	var sinonimos = data["sinonimos"] if data.has("sinonimos") else {}
	var resp = normalizar_texto(respuesta_usuario)

	var pct_clave = porcentaje_palabras_clave(resp, palabras_clave, sinonimos)
	var similitud = similitud_ortografica(resp, modelo)

	var resultado := ""
	var mensaje := ""

	if pct_clave >= 0.80 and similitud >= 0.60:
		resultado = "correcta"
		mensaje = "✔ Muy bien, tu respuesta es correcta."

	elif pct_clave >= 0.50 and similitud >= 0.40:
		resultado = "parcial"
		mensaje = "◐ Casi correcta. Puedes mejorar algunos detalles."

	else:
		resultado = "incorrecta"
		mensaje = "✖ Incorrecto.\nLa respuesta correcta es:\n" + data["respuesta_modelo"]

	return {
		"resultado": resultado,
		"mensaje": mensaje,
		"palabras_clave_pct": pct_clave,
		"similitud": similitud
	}


# -----------------------------------------------------
# Validar respuesta al presionar botón
# -----------------------------------------------------
func _on_validar_pressed():
	if pregunta_actual == "":
		mensaje.text = "❌ No hay pregunta actual."
		return

	var resultado = evaluar_respuesta(pregunta_actual, respuesta.text)
	mensaje.text = resultado["mensaje"]

	if resultado["resultado"] != "incorrecta":
		indice_pregunta += 1
		await get_tree().create_timer(1.5).timeout
		mostrar_pregunta()
