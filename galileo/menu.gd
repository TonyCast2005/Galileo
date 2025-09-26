extends Control

func _on_perfil_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/usuario/profile.tscn")

func _on_leccion_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/usuario/LeccionesInicio.tscn")

func _on_estadistica_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/usuario/estadisticas.tscn") # asegúrate de poner el archivo .tscn correcto
