extends Panel

@onready var icon_texture = $HBoxContainer/FotoLogro
@onready var nombre_label = $HBoxContainer/VBoxContainer/Nombre
@onready var descripcion_label = $HBoxContainer/VBoxContainer/textoLectura
@onready var overlay_bloqueado = $OverlayBloqueado

func set_data(icon: Texture, title: String, description: String, unlocked: bool):
	# Asigna la textura
	if icon_texture and icon:
		icon_texture.texture = icon
	else:
		print("⚠ No se pudo asignar textura para:", title)

	# Asigna el texto
	if nombre_label:
		nombre_label.text = title
	if descripcion_label:
		descripcion_label.text = description

	# Muestra u oculta el overlay según si está bloqueado
