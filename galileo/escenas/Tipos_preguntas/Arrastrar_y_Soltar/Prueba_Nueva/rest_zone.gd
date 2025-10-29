extends Marker2D

@export var rect_size = Vector2(120, 60) # 🔹 Más grande
@export var corner_radius := 10.0        # 🔹 Bordes redondeados
var ocupado := false

# Colores
var color_libre = Color(0.3, 0.0, 0.5, 0.5)   # Morado oscuro translúcido
var color_ocupado = Color(1, 1, 1, 0.8)       # Blanco con leve transparencia
var color_seleccionado = Color(1, 1, 1, 0.8) # Dorado suave al seleccionar

func _ready():
    ocupado = false
    if not is_in_group("zone"):
        add_to_group("zone")
    queue_redraw()

func _draw():
    var top_left = -rect_size / 2
    var rect = Rect2(top_left, rect_size)
    var color = color_ocupado if ocupado else color_libre

    # Creamos un StyleBoxFlat con esquinas redondeadas
    var style = StyleBoxFlat.new()
    style.bg_color = color
    # radios por esquina (puedes cambiar individualmente si quieres)
    style.corner_radius_top_left = corner_radius
    style.corner_radius_top_right = corner_radius
    style.corner_radius_bottom_left = corner_radius
    style.corner_radius_bottom_right = corner_radius

    # Borde: definimos cada lado por separado (no existe border_width_all)
    style.border_color = Color.BLACK
    style.border_width_top = 2
    style.border_width_bottom = 2
    style.border_width_left = 2
    style.border_width_right = 2

    # Dibujamos el rectángulo redondeado usando el StyleBox
    draw_style_box(style, rect)

func select():
    for child in get_tree().get_nodes_in_group("zone"):
        if child != self and child.has_method("deselect"):
            child.deselect()
    modulate = color_seleccionado
    queue_redraw()

func deselect():
    modulate = Color.WHITE
    queue_redraw()

func set_ocupado(value: bool):
    ocupado = value
    queue_redraw()
