extends Control

@onready var label_pregunta = $TextoPregunta
@onready var boton_verdadero = $Verdadero
@onready var boton_falso = $Falso
@onready var mensaje = $Mensaje

signal respondida(texto: String, color: Color, correcta: bool)
var preguntas = []
var indice_actual = 0
const FIREBASE_URL = "https://galileo-af640-default-rtdb.firebaseio.com/preguntas_VF.json"

func _ready():
	cargar_preguntas()

func cargar_preguntas():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	http.request(FIREBASE_URL)

func _on_request_completed(result, response_code, headers, body):
	print("Código de respuesta Firebase:", response_code)
	print("Respuesta:", body.get_string_from_utf8())

	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())

		if typeof(data) == TYPE_ARRAY:
			for pregunta in data:
				if pregunta != null:
					preguntas.append(pregunta)
		elif typeof(data) == TYPE_DICTIONARY:
			for id in data.keys():
				preguntas.append(data[id])

		if preguntas.size() > 0:
			mostrar_pregunta(indice_actual)
		else:
			label_pregunta.text = "No se encontraron preguntas."
	else:
		label_pregunta.text = "Error al conectar con Firebase."


func mostrar_pregunta(indice):
	if indice >= preguntas.size():
		label_pregunta.text = "Tengo que agregar más preguntas DX"
		boton_verdadero.disabled = true
		boton_falso.disabled = true
		return

	var pregunta = preguntas[indice]
	label_pregunta.text = pregunta.get("pregunta", "Pregunta no encontrada")
	var correcta = pregunta.get("respuesta_correcta", "")

	for s in boton_verdadero.pressed.get_connections():
		boton_verdadero.pressed.disconnect(s["callable"])
	for s in boton_falso.pressed.get_connections():
		boton_falso.pressed.disconnect(s["callable"])

	boton_verdadero.text = "Verdadero"
	boton_falso.text = "Falso"

	boton_verdadero.pressed.connect(func(): responder("Verdadero", correcta))
	boton_falso.pressed.connect(func(): responder("Falso", correcta))

func responder(respuesta: String, correcta: String):
	if respuesta == correcta:
		mensaje.text = "¡Correcto!"
		await get_tree().create_timer(2.0).timeout
		mensaje.text = ""
	else:
		mensaje.text = "Incorrecto"
		await get_tree().create_timer(2.0).timeout
		mensaje.text = ""

	await get_tree().create_timer(1.5).timeout
	indice_actual += 1
	mostrar_pregunta(indice_actual)
