extends Panel

@onready var icon_rect: TextureRect = $HBoxContainer/TextureRect
@onready var title_label: Label = $Nombre
@onready var desc_label: Label = $textoLectura

var candado_texture: Texture2D = load("res://assets/sprites/ui/bloqueado.png")

func set_data(icon: Texture2D, title: String, description: String, unlocked: bool):
    title_label.text = title
    desc_label.text = description

    if unlocked:
        icon_rect.texture = icon
        modulate = Color(1, 1, 1, 1)  # normal
    else:
        icon_rect.texture = candado_texture
        modulate = Color(1, 1, 1, 0.6)  # tenue opcional
