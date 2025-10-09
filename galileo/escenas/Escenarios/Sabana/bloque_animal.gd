extends Control

@export var animal_name: String
@onready var texture_rect = $TextureRect

func _ready():
    mouse_filter = Control.MOUSE_FILTER_PASS

func _get_drag_data(at_position):
    # Esto se ejecuta cuando el jugador arrastra el bloque
    var preview = TextureRect.new()
    preview.texture = texture_rect.texture
    preview.modulate = Color(1, 1, 1, 0.7)
    set_drag_preview(preview)

    # Puedes enviar el nombre del animal como "data"
    return animal_name
