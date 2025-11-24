extends Control



func _on_volver_pressed():
    # Volví al menú → quiero desbloquear siguiente
    Globals.desbloquear_pendiente = true
    get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")
