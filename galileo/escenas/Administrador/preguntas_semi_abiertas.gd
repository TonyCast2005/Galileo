extends Control
@onready var pregunta = $pregunta
@onready var subpregunta = $subpregunta
@onready var respuesta = $respuesta
@onready var mensaje = $Mensaje

func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")

func _on_previsualizar_pressed() -> void:
	pass # Replace with function body.


func _on_eliminar_pressed() -> void:
	pass # Replace with function body.


func _on_borrador_pressed() -> void:
	pass # Replace with function body.


func _on_guardar_pressed() -> void:
	pass # Replace with function body.
