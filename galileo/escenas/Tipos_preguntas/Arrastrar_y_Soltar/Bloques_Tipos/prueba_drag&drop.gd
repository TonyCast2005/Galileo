extends Node2D



@export var palabra: String = ""  # <- esta se puede cambiar por cada bloque en el editor
var selected = false
var rest_point: Vector2
var rest_zone = null   # referencia a la zona actual (Marker2D)
var rest_nodes: Array = []
var mouse_offset: Vector2 = Vector2.ZERO

func _ready():
    rest_nodes = get_tree().get_nodes_in_group("zone")
    $label.text = palabra  # ✅ muestra la palabra del bloque
    await get_tree().process_frame
    _find_initial_zone()

# 🔹 Busca la zona más cercana libre después de que todo esté cargado
func _find_initial_zone():
    var shortest_dist = INF
    for zone in rest_nodes:
        var d = global_position.distance_to(zone.global_position)
        # Solo tomamos una zona que esté libre
        if d < shortest_dist and not zone.ocupado:
            rest_point = zone.global_position
            rest_zone = zone
            shortest_dist = d
    # Si encontramos una zona válida, la seleccionamos y marcamos ocupada
    if rest_zone:
        if rest_zone.has_method("select"):
            rest_zone.select()
        rest_zone.ocupado = true

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed and get_global_mouse_position().distance_to(global_position) < 75:
                # Inicia arrastre (NO liberamos la zona aún)
                selected = true
                mouse_offset = get_global_mouse_position() - global_position
            elif not event.pressed and selected:
                # Termina arrastre: intentar colocar
                selected = false
                _update_rest_point()

func _physics_process(delta):
    if selected:
        # Bloque sigue al mouse con interpolación suave
        var target = get_global_mouse_position() - mouse_offset
        global_position = global_position.lerp(target, 25 * delta)
        
        # Rotación ligera hacia el movimiento
        var target_angle = (get_global_mouse_position() - global_position).angle()
        var diff = wrapf(target_angle - rotation, -PI, PI)
        diff = clamp(diff, -0.2, 0.2)
        rotation += diff * 0.2
    else:
        # Va a la rest_zone (rest_point) más cercana válida
        global_position = global_position.lerp(rest_point, 10 * delta)
        rotation = lerp_angle(rotation, 0, 10 * delta)

# 🔹 Recalcula la zona más cercana al soltar y gestiona ocupación
func _update_rest_point():
    var shortest_dist = 75
    var nueva_zona = null
    for zone in rest_nodes:
        var distance = global_position.distance_to(zone.global_position)
        # Permitimos la zona si está libre o si es la misma zona que ya ocupábamos
        if distance < shortest_dist and (not zone.ocupado or zone == rest_zone):
            nueva_zona = zone
            shortest_dist = distance

    if nueva_zona:
        # Si la nueva zona es distinta de la anterior, transferimos la ocupación
        if nueva_zona != rest_zone:
            nueva_zona.ocupado = true
            if nueva_zona.has_method("select"):
                nueva_zona.select()
            if rest_zone:
                rest_zone.ocupado = false
        # Actualizamos referencia y punto objetivo
        rest_zone = nueva_zona
        rest_point = nueva_zona.global_position
        
        # ✅ Verificamos si la palabra es correcta (si la zona tiene esa función)
        if nueva_zona.has_method("verificar"):
            nueva_zona.verificar(self)
    else:
        # No hay zona libre cercana: volver al último punto válido (rest_zone)
        if rest_zone:
            rest_point = rest_zone.global_position
        else:
            print("❌ No hay zona válida y no hay rest_zone previa")

# 🔹 Para liberar manualmente la zona actual
func liberar_zona_actual():
    if rest_zone and "ocupado" in rest_zone:
        rest_zone.ocupado = false
        rest_zone = null
