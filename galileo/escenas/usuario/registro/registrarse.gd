extends Control
var change_scene = preload("res://escenas/usuario/registro/iniciarSesion.tscn")

func _on_inicias_sesion_pressed() -> void:
	get_tree().change_scene_to_packed(change_scene)
	pass # Replace with function body.
