extends Control

@onready var enunciado = $Enunciado
@onready var op_v = $MarginContainer/VBoxContainer/opcion_verdadero
@onready var op_f = $MarginContainer/VBoxContainer/opcion_falso
@onready var btn_verificar = $MarginContainer/VBoxContainer/btn_verificar
@onready var retro = $MarginContainer/VBoxContainer/retro

var data = {}

func _ready():
	# Cargar los datos enviados desde el administrador
	if Globals.has("temp_preview_data"):
		data = Globals.temp_preview_data
	else:
		data = {}

	# Llenar el texto
	enunciado.text = data.get("enunciado", "Sin enunciado")

	op_v.button_pressed = false
	op_f.button_pressed = false

	# Asegurar que la retroalimentación se oculte
	retro.visible = false

	# Conectar el botón
	btn_verificar.pressed.connect(_on_verificar)

func _on_verificar():
	# Evita que ambos estén seleccionados
	if op_v.button_pressed and op_f.button_pressed:
		retro.text = "Selecciona solo una opción."
		retro.visible = true
		return

	var respuesta_usuario = ""
	if op_v.button_pressed:
		respuesta_usuario = "verdadero"
	elif op_f.button_pressed:
		respuesta_usuario = "falso"
	else:
		retro.text = "Selecciona una respuesta."
		retro.visible = true
		return

	var correcta = data.get("respuesta_correcta", "")
	var retro_v = data.get("retro_verdadero", "Retroalimentación no disponible.")
	var retro_f = data.get("retro_falso", "Retroalimentación no disponible.")

	# Mostrar retroalimentación
	if respuesta_usuario == correcta:
		if respuesta_usuario == "verdadero":
			retro.text = retro_v
		else:
			retro.text = retro_f

		retro.modulate = Color(0.1, 0.7, 0.1) # verde
	else:
		if respuesta_usuario == "verdadero":
			retro.text = retro_v
		else:
			retro.text = retro_f

		retro.modulate = Color(0.8, 0.2, 0.2) # rojo

	retro.visible = true

func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")
