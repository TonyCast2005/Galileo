extends Panel

@onready var icon_texture = $HBoxContainer/FotoLogro
@onready var nombre_label = $HBoxContainer/VBoxContainer/Nombre
@onready var descripcion_label = $HBoxContainer/VBoxContainer/textoLectura
@onready var overlay_bloqueado = $OverlayBloqueado

func set_data(icon: Texture, title: String, description: String, unlocked: bool):

	if icon_texture and icon:
		icon_texture.texture = icon
	else:
		print("No se pudo asignar textura para:", title)

	if nombre_label:
		nombre_label.text = title
	if descripcion_label:
		descripcion_label.text = description
