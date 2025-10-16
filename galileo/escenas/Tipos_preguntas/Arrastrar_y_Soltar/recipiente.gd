extends Area2D

@onready var color_rect = $ColorRect  # o Label/Sprite2D si usas otro nodo visual

func _ready():
		add_to_group("dropable")
		set_meta("ocupado", false)
		if color_rect:
			color_rect.modulate = Color(0.6, 0.4, 0.8, 0.7)

func _on_body_entered(body):
	if body.is_in_group("draggable_block"):
		if color_rect:
			color_rect.modulate = Color(Color.PURPLE, 1)

func _on_body_exited(body):
	if body.is_in_group("draggable_block"):
		if color_rect:
			color_rect.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
var ocupado := false
