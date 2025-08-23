extends ScrollContainer

var velocity := 0.0
var is_dragging := false
var last_touch_y := 0.0
var friction := 1500.0  # Cambia para ajustar el frenado

func _unhandled_input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            is_dragging = true
            velocity = 0.0
            last_touch_y = event.position.y
        else:
            is_dragging = false
    elif event is InputEventScreenDrag and is_dragging:
        var dy = event.position.y - last_touch_y
        last_touch_y = event.position.y
        scroll_vertical -= dy
        velocity = -dy / event.relative.length() * 1000.0  # Escala la velocidad para la inercia

func _process(delta):
    if not is_dragging:
        if abs(velocity) > 1.0:
            scroll_vertical += velocity * delta
            velocity = move_toward(velocity, 0, friction * delta)
