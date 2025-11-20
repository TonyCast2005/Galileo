extends Panel

@onready var icon_rect = $HBoxContainer/TextureRect
@onready var title_label = $HBoxContainer/VBoxContainer/Nombre
@onready var desc_label = $HBoxContainer/VBoxContainer/textoLectura
@onready var overlay = $OverlayBloqueado

func set_data(icon: Texture, title: String, description: String, unlocked: bool):
	icon_rect.texture = icon
	title_label.text = title
	desc_label.text = description

	overlay.visible = not unlocked
	modulate = Color(1, 1, 1, 1.0 if unlocked else 0.5)
