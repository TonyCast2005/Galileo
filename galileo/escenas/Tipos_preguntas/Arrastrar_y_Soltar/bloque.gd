extends Node2D

@onready var label := $Label
var is_dragging := false
var mouse_offset := Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and label.get_rect().has_point(to_local(event.position)):
			is_dragging = true
			mouse_offset = event.position - global_position
			label.modulate = Color(1, 1, 0.7)
		elif not event.pressed and is_dragging:
			is_dragging = false
			label.modulate = Color(1, 1, 1)
			_snap_to_drop_zone()

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() - mouse_offset

func _snap_to_drop_zone():
	var space_state = get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collide_with_areas = true
	var result = space_state.intersect_point(query)

	for hit in result:
		if hit.collider.is_in_group("dropable"):
			print("✅ Bloque soltado en recipiente")
			var tween := get_tree().create_tween()
			tween.tween_property(self, "global_position", hit.collider.global_position, 0.2)
			return
	print("❌ Bloque soltado fuera de recipientes")
