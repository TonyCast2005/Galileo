extends Area2D

@onready var color_rect = $ColorRect  # o Label/Sprite2D si usas otro nodo visual

func _ready():
	if color_rect:
		color_rect.modulate = Color(Color.REBECCA_PURPLE, 0.7)

func _on_body_entered(body):
	if body.is_in_group("draggable_block"):
		if color_rect:
			color_rect.modulate = Color(Color.PURPLE, 1)

func _on_body_exited(body):
	if body.is_in_group("draggable_block"):
		if color_rect:
			color_rect.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
