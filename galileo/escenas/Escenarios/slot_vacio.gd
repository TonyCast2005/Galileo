extends Control

var ocupado = false
@onready var texture_rect = $TextureRect

func _can_drop_data(at_position, data):
    return not ocupado  # solo acepta si está vacío

func _drop_data(at_position, data):
    if ocupado:
        return
    ocupado = true
    texture_rect.texture = load("res://assets/sprites/animales/%s.png" % data)
