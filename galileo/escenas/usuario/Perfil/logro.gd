extends Panel

@onready var icon_rect: TextureRect = $HBoxContainer/TextureRect
@onready var title_label: Label = $HBoxContainer/VBoxContainer/Nombre
@onready var desc_label: Label = $HBoxContainer/VBoxContainer/textoLectura
@onready var overlay: Control = $OverlayBloqueado

func set_data(icon: Texture2D, title: String, description: String, unlocked: bool):
	if icon_rect and icon:
		icon_rect.texture = icon

	title_label.text = title
	desc_label.text = description

	overlay.visible = not unlocked

	modulate = Color(1, 1, 1, 1.0 if unlocked else 5.5)
