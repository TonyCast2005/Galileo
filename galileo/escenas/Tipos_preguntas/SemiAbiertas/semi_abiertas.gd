extends Control

@onready var texto_pregunta1 = $TextoPregunta1
@onready var texto_pregunta2 = $TextoPregunta2
@onready var entrada_respuesta = $respuesta
@onready var boton_validar = $validar
@onready var pista = $Pista
@onready var nombre_leccion = $NombreLección
@onready var mensaje = $Mensaje

var preguntas = []
var indice_actual = 0
const FIREBASE_URL = "https://galileo-af640-default-rtdb.firebaseio.com/preguntas_semiabiertas.json"

func _ready():
	cargar_preguntas()

func cargar_preguntas():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	http.request(FIREBASE_URL)

func _on_request_completed(result, response_code, headers, body):
	print("Código Firebase:", response_code)
	print("Respuesta:", body.get_string_from_utf8())

	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())

		if typeof(data) == TYPE_ARRAY:
			for p in data:
				if p != null:
					preguntas.append(p)
		elif typeof(data) == TYPE_DICTIONARY:
			for id in data.keys():
				preguntas.append(data[id])

		if preguntas.size() > 0:
			mostrar_pregunta(indice_actual)
		else:
			texto_pregunta1.text = "No se encontraron preguntas."
	else:
		texto_pregunta1.text = "Error al conectar con Firebase."

func mostrar_pregunta(indice):
	if indice >= preguntas.size():
		texto_pregunta1.text = "se acabó :b"
		texto_pregunta2.text = ""
		boton_validar.disabled = true
		return

	var pregunta = preguntas[indice]
	texto_pregunta1.text = pregunta.get("pregunta", "Pregunta no encontrada")
	texto_pregunta2.text = pregunta.get("subpregunta", "") # opcional
	entrada_respuesta.text = ""
	pista.text = ""
	boton_validar.disabled = false

	for s in boton_validar.pressed.get_connections():
		boton_validar.pressed.disconnect(s["callable"])

	boton_validar.pressed.connect(func(): validar_respuesta(pregunta))

func validar_respuesta(pregunta: Dictionary):
	var correcta = pregunta.get("respuesta_correcta", "").to_lower().strip_edges()
	var respuesta_usuario = entrada_respuesta.text.to_lower().strip_edges()

	if respuesta_usuario == correcta:
		mensaje.text = "¡Correcto!"
		await get_tree().create_timer(2.0).timeout
		mensaje.text = ""
	else:
		mensaje.text = "Incorrecto."
		await get_tree().create_timer(2.0).timeout
		mensaje.text = ""

	await get_tree().create_timer(1.5).timeout
	indice_actual += 1
	mostrar_pregunta(indice_actual)
