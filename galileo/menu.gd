extends MenuBar

func _on_perfil_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/usuario/perfil.tscn")

func _on_leccion_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/usuario/lecciones.tscn")

func _on_estadistica_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/usuario/estadisticas.tscn") # asegúrate de poner el archivo .tscn correcto
