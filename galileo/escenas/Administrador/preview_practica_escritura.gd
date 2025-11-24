extends Control

@onready var lbl_enunciado = $Enunciado
@onready var lbl_codigo = $Codigo
@onready var cont_campos = $Campos
@onready var btn_volver = $volver

func _ready():
	# Cargar datos enviados desde el administrador
	var data = Globals.temp_preview_data

	if data == null:
		lbl_enunciado.text = "No hay datos para previsualizar."
		return

	lbl_enunciado.text = data.get("enunciado", "Sin enunciado")
	lbl_codigo.text = data.get("plantilla", "")

	# Crear campos vacíos según el número de respuestas
	var campos = data.get("respuestas_correctas", [])
	var cantidad = data.get("campos", campos.size())

	# limpiar contenedor
	for c in cont_campos.get_children():
		c.queue_free()

	for i in range(cantidad):
		var input := LineEdit.new()
		input.editable = false
		input.placeholder_text = "Respuesta " + str(i + 1)
		cont_campos.add_child(input)


func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/practicaEscritura.tscn")
