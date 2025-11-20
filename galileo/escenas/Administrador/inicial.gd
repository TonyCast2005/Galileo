extends Control


func _on_leccion_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarLección.tscn")

func _on_preguntas_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")

func _on_logros_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/logros.tscn")
