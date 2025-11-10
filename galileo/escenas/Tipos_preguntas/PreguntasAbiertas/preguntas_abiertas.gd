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
# INICIO
# -----------------------------------------------------
func _ready():
	titulo.text = "Preguntas abiertas - Lección 1"
	await cargar_preguntas()
	if preguntas.size() > 0:
		mostrar_pregunta()
	else:
		mensaje.text = "❌ No se pudieron cargar las preguntas."

	validar.pressed.connect(_on_validar_pressed)

# -----------------------------------------------------
# CARGAR PREGUNTAS DESDE FIREBASE
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

	# En Firebase puede venir como array o diccionario
	if typeof(data) == TYPE_ARRAY:
		for item in data:
			if item == null:
				continue
			preguntas[item["pregunta"]] = item
	elif typeof(data) == TYPE_DICTIONARY:
		for k in data.keys():
			var item = data[k]
			preguntas[item["pregunta"]] = item
	else:
		push_error("❌ Error al parsear preguntas desde Firebase")
	http.queue_free()

# -----------------------------------------------------
# MOSTRAR UNA PREGUNTA EN PANTALLA
# -----------------------------------------------------
func mostrar_pregunta():
	var claves = preguntas.keys()
	if indice_pregunta >= claves.size():
		mensaje.text = "🎉 Has respondido todas las preguntas."
		label_pregunta.text = ""
		validar.disabled = true
		return

	pregunta_actual = claves[indice_pregunta]
	label_pregunta.text = pregunta_actual
	respuesta.text = ""
	mensaje.text = ""

# -----------------------------------------------------
# NORMALIZAR TEXTO
# -----------------------------------------------------
func normalizar_texto(texto: String) -> String:
	var articulos = [" el ", " la ", " los ", " las ", " un ", " una ", " unos ", " unas "]
	texto = texto.strip_edges().to_lower()
	for a in articulos:
		texto = texto.replace(a, " ")
	return texto.strip_edges()

# -----------------------------------------------------
# COMPROBAR PALABRAS CLAVE
# -----------------------------------------------------
func contiene_palabras_clave(respuesta: String, palabras_clave: Array, sinonimos: Dictionary) -> bool:
	for palabra in palabras_clave:
		if palabra in respuesta:
			return true
		if sinonimos.has(palabra):
			for s in sinonimos[palabra]:
				if s in respuesta:
					return true
	return false

# -----------------------------------------------------
# DISTANCIA DE LEVENSHTEIN
# -----------------------------------------------------
func levenshtein(a: String, b: String) -> int:
	var m = a.length()
	var n = b.length()
	var matrix = []
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
			var costo = 0 if a[i - 1] == b[j - 1] else 1
			matrix[i][j] = min(
				matrix[i - 1][j] + 1,
				matrix[i][j - 1] + 1,
				matrix[i - 1][j - 1] + costo
			)
	return matrix[m][n]

# -----------------------------------------------------
# EVALUAR RESPUESTA (más flexible)
# -----------------------------------------------------
func evaluar_respuesta(pregunta: String, respuesta_usuario: String) -> Dictionary:
	if not preguntas.has(pregunta):
		return {"error": "Pregunta no encontrada"}

	var data = preguntas[pregunta]
	var respuesta_modelo = normalizar_texto(data["respuesta_modelo"])
	var palabras_clave = data["palabras_clave"]
	var sinonimos = data["sinonimos"] if data.has("sinonimos") and typeof(data["sinonimos"]) == TYPE_DICTIONARY else {}

	var respuesta_normalizada = normalizar_texto(respuesta_usuario)

	# 1️⃣ Verificar palabras clave o sinónimos
	var contiene = contiene_palabras_clave(respuesta_normalizada, palabras_clave, sinonimos)

	# 2️⃣ Calcular similitud promedio palabra por palabra
	var distancia_total = 0
	var palabras_usuario = respuesta_normalizada.split(" ", false)
	var palabras_modelo = respuesta_modelo.split(" ", false)
	var conteo = 0

	for palabra_u in palabras_usuario:
		var mejor = 9999
		for palabra_m in palabras_modelo:
			var d = levenshtein(palabra_u, palabra_m)
			if d < mejor:
				mejor = d
		if mejor < 5: # Si son parecidas
			distancia_total += mejor
			conteo += 1

	var distancia_promedio = 0 if conteo == 0 else float(distancia_total) / conteo

	# 3️⃣ Clasificar resultado
	if contiene and distancia_promedio < 3:
		return {
			"resultado": "correcta",
			"mensaje": "✅ ¡Excelente! Tu respuesta es correcta.",
			"distancia_promedio": distancia_promedio
		}
	elif contiene and distancia_promedio <= 5:
		return {
			"resultado": "parcialmente correcta",
			"mensaje": "⚠️ Tu respuesta está cerca, revisa algunos detalles.",
			"distancia_promedio": distancia_promedio
		}
	else:
		return {
			"resultado": "incorrecta",
			"mensaje": "❌ Revisa el concepto. La respuesta correcta es:\n" + data["respuesta_modelo"],
			"distancia_promedio": distancia_promedio
		}

# -----------------------------------------------------
# VALIDAR RESPUESTA Y AVANZAR
# -----------------------------------------------------
func _on_validar_pressed() -> void:
	if pregunta_actual == "":
		mensaje.text = "❌ No hay pregunta actual."
		return

	var resultado = evaluar_respuesta(pregunta_actual, respuesta.text)
	mensaje.text = resultado["mensaje"]

	if resultado["resultado"] != "incorrecta":
		indice_pregunta += 1
		await get_tree().create_timer(1.5).timeout
		mostrar_pregunta()
