extends Node2D

@onready var label := $Label
var is_dragging := false
var mouse_offset := Vector2.ZERO
var start_position := Vector2.ZERO
var recipiente_actual: Area2D = null
var contenedor_origen: Node = null

func _ready():
	await get_tree().process_frame
	start_position = global_position
	contenedor_origen = get_parent() 
	print("Posición inicial registrada:", start_position)
	print("Contenedor original:", contenedor_origen.name)

# ---------------------------------------------------------------
#  DETECCIÓN DE DRAG
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
#  DETECCIÓN DE RECIPIENTE
# ---------------------------------------------------------------
func _snap_to_drop_zone():
	var space_state = get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)

	if results.is_empty():
		print("No se soltó sobre ningún recipiente")
		_regresar_a_inicio()
		return

	for hit in results:
		var recipiente = hit.collider
		if recipiente and recipiente.is_in_group("dropable"):

			if recipiente.has_meta("ocupado") and recipiente.get_meta("ocupado") == true:
				print("El recipiente", recipiente.name, "ya tiene un bloque. Se devuelve.")
				_regresar_a_inicio()
				return

			if recipiente_actual and is_instance_valid(recipiente_actual):
				recipiente_actual.set_meta("ocupado", false)

			recipiente.set_meta("ocupado", true)
			recipiente_actual = recipiente

			var color_rect = recipiente.get_node_or_null("ColorRect")
			var target_pos: Vector2
			
			if color_rect:
			   # Obtiene el rectángulo global del ColorRect
				var rect_global = color_rect.get_global_rect()

# Calcula el centro absoluto del ColorRect
				var global_center = rect_global.position + rect_global.size / 2

# Centra el bloque tomando en cuenta su tamaño
				target_pos = global_center - label.size / 2

# Pequeño ajuste visual opcional
				target_pos.y -= 9

			else:
				  target_pos = recipiente.to_global(Vector2.ZERO)

			print(" Bloque colocado en:", recipiente.name)

			var tween := get_tree().create_tween()
			tween.tween_property(self, "global_position", target_pos, 0.25).set_ease(Tween.EASE_OUT)
			return

	_regresar_a_inicio()

func _regresar_a_inicio():
	if recipiente_actual and is_instance_valid(recipiente_actual):
		recipiente_actual.set_meta("ocupado", false)
		recipiente_actual = null

	print("↩️ Regresando bloque al contenedor original")

	var contenedor_opc = get_tree().get_first_node_in_group("contenedor_opc")

	if contenedor_opc:
		get_parent().remove_child(self)

		contenedor_opc.add_child(self)
		
		await get_tree().process_frame 
		global_position = start_position 
		scale = Vector2.ONE
		rotation = 0
		print("Bloque devuelto correctamente")
	else:
		print("No se encontró el GridContainer (contenedor_opc)")
