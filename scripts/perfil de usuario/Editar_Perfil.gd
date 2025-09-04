extends Control


func _on_perfil_button_pressed():
    get_tree().change_scene_to_file("res://scenes/ui/usuario/profile.tscn")


func _on_edit_avatar_pressed() -> void:
    pass # Replace with function body.


func _on_edit_contra_pressed() -> void:
    pass # Replace with function body.


func _on_edit_perfil_pressed():
    get_tree().change_scene_to_file("res://scenes/ui/usuario/editarperfil/editar_perfil.tscn")
