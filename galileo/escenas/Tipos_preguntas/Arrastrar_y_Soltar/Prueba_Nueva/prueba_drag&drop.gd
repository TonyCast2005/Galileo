extends Node2D

var selected = false
var rest_point : Vector2
var rest_zone = null   # referencia a la zona actual (Marker2D)
var rest_nodes : Array = []
var mouse_offset : Vector2 = Vector2.ZERO

func _ready():
    rest_nodes = get_tree().get_nodes_in_group("zone")

    # Coloca el bloque en la rest_zone más cercana al inicio
    var shortest_dist = INF
    for zone in rest_nodes:
        var d = global_position.distance_to(zone.global_position)
        if d < shortest_dist:
            rest_point = zone.global_position
            rest_zone = zone
            shortest_dist = d
            if zone.has_method("select"):
                zone.select()
            # Marca la zona como ocupada por este bloque
            zone.ocupado = true

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

# Recalcula la rest_zone más cercana al soltar y gestiona ocupación
func _update_rest_point():
    var shortest_dist = 75
    var nueva_zona = null
    for zone in rest_nodes:
        var distance = global_position.distance_to(zone.global_position)
        # Permitimos la zona si está libre o si es la misma zona que ya ocupábamos
        if distance < shortest_dist and (not ("ocupado" in zone and zone.ocupado) or zone == rest_zone):
            nueva_zona = zone
            shortest_dist = distance

    if nueva_zona:
        # Si la nueva zona es distinta de la anterior, transferimos la ocupación
        if nueva_zona != rest_zone:
            # Marcar nueva como ocupada
            nueva_zona.ocupado = true
            if nueva_zona.has_method("select"):
                nueva_zona.select()
            # Liberar la anterior (si existe)
            if rest_zone:
                rest_zone.ocupado = false
        # Actualizamos referencia y punto objetivo
        rest_zone = nueva_zona
        rest_point = nueva_zona.global_position
    else:
        # No hay zona libre cercana: volver al último punto válido (rest_zone)
        # Si no tenemos rest_zone, mantener la posición actual y mostrar mensaje
        if rest_zone:
            rest_point = rest_zone.global_position
        else:
            print("❌ No hay zona válida y no hay rest_zone previa")

# Si quieres usar liberar manualmente en otro momento (p. ej. al eliminar el bloque)
func liberar_zona_actual():
    if rest_zone and "ocupado" in rest_zone:
        rest_zone.ocupado = false
        rest_zone = null
