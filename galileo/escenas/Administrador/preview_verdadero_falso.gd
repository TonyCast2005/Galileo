extends Control

@onready var enunciado = $Enunciado
@onready var op_v = $Verdadero
@onready var op_f = $Falso
@onready var retro = $Mensaje  # Cambia si tu label de retroalimentación se llama distinto

var data = {}

func _ready():
	data = Globals.temp_preview_data

	if data.is_empty():
		enunciado.text = "Sin enunciado"
		return

	# Establecer texto
	enunciado.text = data.get("enunciado", "Sin enunciado")

	# Reset botones
	op_v.disabled = false
	op_f.disabled = false
	op_v.text = "Verdadero"
	op_f.text = "Falso"

	# Conectar opciones
	op_v.pressed.connect(func(): _verificar("Verdadero"))
	op_f.pressed.connect(func(): _verificar("Falso"))

	# Ocultar retro de inicio
	retro.visible = false

func _verificar(respuesta_usuario: String):
	var correcta = data.get("respuesta_correcta", "")

	var retro_v = data.get("retro_verdadero", "Sin retroalimentación.")
	var retro_f = data.get("retro_falso", "Sin retroalimentación.")

	if respuesta_usuario == correcta:
		if respuesta_usuario == "Verdadero":
			retro.text = retro_v
		else:
			retro.text = retro_f
			
	else:
		if respuesta_usuario == "Verdadero":
			retro.text = retro_v
		else:
			retro.text = retro_f

	retro.visible = true


func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/verdaderoFalso.tscn")
