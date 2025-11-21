extends Control

@onready var label_pregunta = $TextoPregunta
@onready var boton1 = $Opcion1
@onready var boton2 = $Opcion2
@onready var boton3 = $Opcion3
@onready var mensaje = $Mensaje

var data = {}

func _ready():
	# Obtener los datos almacenados en Globals
	data = Globals.temp_preview_data

	if data.is_empty():
		label_pregunta.text = "Sin datos para previsualizar."
		return

	# Establecer textos
	label_pregunta.text = data.get("pregunta", "Sin enunciado")
	boton1.text = data.get("opcion1", "Opción 1")
	boton2.text = data.get("opcion2", "Opción 2")
	boton3.text = data.get("opcion3", "Opción 3")

	var correcta = int(data.get("correcta", 1))

	# Limpiar señales previas
	for s in boton1.pressed.get_connections(): boton1.pressed.disconnect(s["callable"])
	for s in boton2.pressed.get_connections(): boton2.pressed.disconnect(s["callable"])
	for s in boton3.pressed.get_connections(): boton3.pressed.disconnect(s["callable"])

	# Conectar botones
	boton1.pressed.connect(func(): responder(1, correcta))
	boton2.pressed.connect(func(): responder(2, correcta))
	boton3.pressed.connect(func(): responder(3, correcta))

	# Ocultar mensaje al inicio
	mensaje.visible = false


func responder(seleccionada:int, correcta:int):
	if seleccionada == correcta:
		mensaje.text = "¡Correcto!"
		mensaje.modulate = Color.GREEN
	else:
		mensaje.text = "Incorrecto :("
		mensaje.modulate = Color.RED

	mensaje.visible = true


func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/opcionMultiple.tscn")
