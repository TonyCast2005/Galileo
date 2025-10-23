extends Marker2D

@export var rect_size = Vector2(100, 50)
var ocupado := false  # ← inicializado a falso de forma explícita

# Colores
var color_libre = Color(1, 0.9, 0.7, 0.3)
var color_ocupado = Color(1, 0.3, 0.3, 0.4)
var color_seleccionado = Color(0.6, 0, 0, 0.5)

func _ready():
    # 🔹 Forzamos que siempre empiece libre
    ocupado = false
    if not is_in_group("zone"):
        add_to_group("zone")
    queue_redraw()

func _draw():
    var top_left = -rect_size / 2
    var color = color_ocupado if ocupado else color_libre
    draw_rect(Rect2(top_left, rect_size), color, true)
    draw_rect(Rect2(top_left, rect_size), Color.BLACK, false, 2)

func select():
    for child in get_tree().get_nodes_in_group("zone"):
        if child != self and child.has_method("deselect"):
            child.deselect()
    modulate = Color(1, 0.5, 0.5, 1)
    queue_redraw()

func deselect():
    modulate = Color.WHITE
    queue_redraw()

func set_ocupado(value: bool):
    ocupado = value
    queue_redraw()
