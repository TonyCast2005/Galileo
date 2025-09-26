extends HBoxContainer

@onready var icon_rect = $TextureRect
@onready var title_label = $VBoxContainer/Nombre
@onready var desc_label = $VBoxContainer/textoLectura

func set_data(icon: Texture, title: String, description: String):
	icon_rect.texture = icon
	title_label.text = title
	desc_label.text = description
