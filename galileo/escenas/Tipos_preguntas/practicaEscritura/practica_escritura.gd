extends Control

@onready var lbl_enunciado = $Enunciado
@onready var lbl_codigo = $Codigo
@onready var cont_campos = $Campos
@onready var retro = $Retro

var preguntas = []
var indice_actual = 0
var respuestas_correctas = []
var campos = []

const FIREBASE_URL = "https://galileo-af640-default-rtdb.firebaseio.com/practica_escritura.json"

func _ready():
	cargar_preguntas()

# ============================================================
# CARGAR TODAS LAS PREGUNTAS DESDE FIREBASE
# ============================================================
func cargar_preguntas():
	var http = HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(_on_request_completed)
	http.request(FIREBASE_URL)


func _on_request_completed(result, response_code, headers, body):
	print("Código Firebase:", response_code)

	if response_code != 200:
		lbl_enunciado.text = "Error al conectar con Firebase."
		return

	var data = JSON.parse_string(body.get_string_from_utf8())

	# Convertir correctamente la base de datos a lista usable
	if typeof(data) == TYPE_DICTIONARY:
		for id in data.keys():
			if data[id] != null and typeof(data[id]) == TYPE_DICTIONARY:
				preguntas.append(data[id])

	elif typeof(data) == TYPE_ARRAY:
		for p in data:
			if p != null and typeof(p) == TYPE_DICTIONARY:
				preguntas.append(p)

	print("Preguntas válidas encontradas:", preguntas.size())

	if preguntas.is_empty():
		lbl_enunciado.text = "No hay preguntas disponibles."
		return

	indice_actual = 0
	mostrar_pregunta(indice_actual)

	
# ============================================================
# MOSTRAR PREGUNTA
# ============================================================
func mostrar_pregunta(i):

	# No más preguntas
	if i >= preguntas.size():
		lbl_enunciado.text = "¡Felicidades! Terminaste."
		cont_campos.visible = false
		return

	var pregunta = preguntas[i]

	# Seguridad
	if pregunta == null or typeof(pregunta) != TYPE_DICTIONARY:
		print("⚠ Pregunta inválida o nula, saltando...")
		indice_actual += 1
		mostrar_pregunta(indice_actual)
		return

	# Corrección automática por si la BD usa "respuesta_correcta"
	if pregunta.has("respuesta_correcta"):
		pregunta["respuestas_correctas"] = pregunta["respuesta_correcta"]

	lbl_enunciado.text = pregunta.get("enunciado", "Sin enunciado")
	lbl_codigo.text = pregunta.get("plantilla", "")

	respuestas_correctas = pregunta.get("respuestas_correctas", [])
	var cantidad = pregunta.get("campos", respuestas_correctas.size())

	# LIMPIAR CAMPOS ANTERIORES
	for c in cont_campos.get_children():
		c.queue_free()
	campos.clear()

	# CREAR LOS CAMPOS NUEVOS
	for k in range(cantidad):
		var input := LineEdit.new()
		input.placeholder_text = "Respuesta " + str(k + 1)
		cont_campos.add_child(input)
		campos.append(input)

	retro.text = ""
	retro.modulate = Color.WHITE


# ============================================================
# VALIDAR RESPUESTA
# ============================================================
func _on_btn_validar_pressed():

	if campos.is_empty():
		return

	for i in range(campos.size()):
		var user = campos[i].text.strip_edges()
		var correct = respuestas_correctas[i]

		if user != correct:
			retro.text = "Incorrecto"
			retro.modulate = Color.RED
			await get_tree().create_timer(1.2).timeout
			indice_actual += 1
			mostrar_pregunta(indice_actual)
			return

	retro.text = "Correcto"
	retro.modulate = Color.GREEN

	await get_tree().create_timer(1.2).timeout
	indice_actual += 1
	mostrar_pregunta(indice_actual)
