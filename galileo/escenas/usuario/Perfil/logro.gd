extends Panel

@onready var icon_rect = $HBoxContainer/FotoLogro
@onready var title_label = $HBoxContainer/VBoxContainer/Nombre
@onready var desc_label = $HBoxContainer/VBoxContainer/textoLectura

func set_data(icon: Texture, title: String, description: String):
	print("DEBUG -> icon_rect:", icon_rect) # 👈 para comprobar
	icon_rect.texture = icon
	title_label.text = title
	desc_label.text = description
