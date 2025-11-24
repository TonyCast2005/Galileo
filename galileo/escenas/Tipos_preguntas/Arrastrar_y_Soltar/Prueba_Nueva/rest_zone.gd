extends Marker2D

@export var rect_size = Vector2(120, 60) # 🔹 Tamaño del área
@export var corner_radius := 10.0        # 🔹 Bordes redondeados
@export var palabra_correcta: String = "" # ✅ La palabra esperada en esta zona
var ocupado := false
var bloque_actual = null

# Colores base
var color_libre = Color(0.3, 0.0, 0.5, 0.5)   # Morado oscuro translúcido
var color_ocupado = Color(1, 1, 1, 0.8)       # Blanco con leve transparencia
var color_correcto = Color(0, 1, 0, 0.6)      # Verde translúcido (correcto)
var color_incorrecto = Color(1, 0, 0, 0.6)    # Rojo translúcido (incorrecto)
var color_seleccionado = Color(1, 1, 1, 0.8)  # Blanco al seleccionar

var estado_color = Color(0.3, 0.0, 0.5, 0.5)  # color actual mostrado

func _ready():
	ocupado = false
	estado_color = color_libre
	if not is_in_group("zone"):
		add_to_group("zone")
	queue_redraw()

func _draw():
	var top_left = -rect_size / 2
	var rect = Rect2(top_left, rect_size)

	var style = StyleBoxFlat.new()
	style.bg_color = estado_color

	# Bordes redondeados
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius

	# Borde negro delgado
	style.border_color = Color.BLACK
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2

	draw_style_box(style, rect)

func select():
	for child in get_tree().get_nodes_in_group("zone"):
		if child != self and child.has_method("deselect"):
			child.deselect()
	estado_color = color_seleccionado
	queue_redraw()

func deselect():
	estado_color = color_ocupado if ocupado else color_libre
	queue_redraw()

func set_ocupado(value: bool):
	ocupado = value
	estado_color = color_ocupado if value else color_libre
	queue_redraw()

# ✅ Verifica si el bloque colocado es correcto
func verificar(bloque):
	bloque_actual = bloque
	ocupado = true
	if bloque.palabra == palabra_correcta:
		estado_color = color_correcto
		print("✅ Correcto:", bloque.palabra)
	else:
		estado_color = color_incorrecto
		print("❌ Incorrecto:", bloque.palabra)
	queue_redraw()
