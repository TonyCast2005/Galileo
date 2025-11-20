extends Control

@onready var label_pregunta = $TextoPregunta
@onready var boton1 = $Opcion1
@onready var boton2 = $Opcion2
@onready var boton3 = $Opcion3

var preguntas = []
var indice_actual = 0

const URL = "https://galileo-af640-default-rtdb.firebaseio.com/preguntas_opc.json"

func _ready():
	cargar_preguntas()

func cargar_preguntas():
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	http.request(URL)

func _on_request_completed(result, response_code, headers, body):
	var data = JSON.parse_string(body.get_string_from_utf8())

	for id in data.keys():
		preguntas.append(data[id])

	mostrar_pregunta(indice_actual)


func mostrar_pregunta(i):
	var p = preguntas[i]

	label_pregunta.text = p["pregunta"]

	var opciones = p["opciones"]
	var correcta = opciones[p["correcta"] - 1]

	boton1.text = opciones[0]
	boton2.text = opciones[1]
	boton3.text = opciones[2]

	for b in [boton1, boton2, boton3]:
		for s in b.pressed.get_connections():
			b.pressed.disconnect(s["callable"])

	boton1.pressed.connect(func(): responder(opciones[0], correcta))
	boton2.pressed.connect(func(): responder(opciones[1], correcta))
	boton3.pressed.connect(func(): responder(opciones[2], correcta))

func responder(r, correcta):
	if r == correcta:
		print("Correcta!")
	else:
		print("Incorrecta!")
