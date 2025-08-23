extends Control

func set_data(icono: Texture, nombre_text: String, descripcion_text: String):
    $HBoxContainer/TextureRect.texture = icono
    $HBoxContainer/VBoxContainer/Nombre.text = nombre_text
    $HBoxContainer/VBoxContainer/descripcion.text = descripcion_text
