extends Control

# Nota: Asumimos que los datos devueltos por MetricsManager.get_radar_scores()
# están en el mismo orden que estas etiquetas:
# [0] Significativo, [1] Descubrimiento, [2] ABE

# Los datos se actualizarán desde MetricsManager en _ready()
var data: Array[float] = [0.0, 0.0, 0.0] 
var labels: Array[String] = ["Significativo", "Descubrimiento", "ABE"]
var radius: float = 260.0

# imágenes para las etiquetas
var label_textures: Array[Texture2D] = [
    preload("res://assets/sprites/aprendizajes/significativo.png"),
    preload("res://assets/sprites/aprendizajes/descubrimiento.png"),
    preload("res://assets/sprites/aprendizajes/teorico.png")
]

# información que mostrará el panel
var label_info: Array[String] = [
    " \nRepresenta tu comprensión profunda de los conceptos clave de Arduino.",
    "\nHas explorado nuevas ideas y aplicado tu curiosidad para aprender más.",
    " \nDemuestra tu dominio en aplicaciones prácticas con Arduino y electrónica."
]


@onready var panel_info = get_parent().get_node("Panel_Info")
@onready var label_title = panel_info.get_node("Label_Title")
@onready var label_info_text = panel_info.get_node("Label_Info")

# parámetros del efecto flotante
var float_speed: float = 1.5
var float_height: float = 10.0
var base_y: float = 0.0

# lista para guardar rectángulos de las imágenes
var label_rects: Array[Rect2] = []

func _ready() -> void:
    base_y = position.y
    label_title.text = "Información"
    label_info_text.text = "Haz clic en un icono del radar para ver detalles."
    _ajustar_panel_a_pantalla()
    
    # ======================================================
    # 🟢 PASO CLAVE: OBTENER DATOS REALES DE LAS MÉTRICAS
    # ======================================================
    # Asegúrate de que esta función exista en tu script MetricsManager.gd
    if MetricsManager.has_method("get_radar_scores"):
        data = MetricsManager.get_radar_scores()
        # Forzamos el redibujado para que el polígono se dibuje inmediatamente
        queue_redraw()
    else:
        # DEBUG: Si la función no existe, mantenemos los valores iniciales (0.0)
        print("ERROR: MetricsManager no tiene la función get_radar_scores(). Usando datos por defecto.")


func _process(delta: float) -> void:
    # Efecto de flotación, usa Time.get_ticks_msec() para un movimiento suave
    position.y = base_y + sin(Time.get_ticks_msec() / 1000.0 * float_speed) * float_height
    queue_redraw()

func _draw() -> void:
    var n: int = data.size()
    if n == 0:
        return
    var angle_step: float = TAU / float(n)

    var center = size / 2.0
    var points: Array[Vector2] = []
    var outer_points: Array[Vector2] = []

    # calcular puntos del radar y del polígono
    for i in range(n):
        var angle: float = -PI / 2.0 + float(i) * angle_step
        # Aseguramos que data[i] esté entre 0 y 1 para que el polígono no se salga
        var score_normalized = clampf(data[i], 0.0, 1.0) 
        var r_val: float = radius * score_normalized
        
        points.append(Vector2(center.x + cos(angle) * r_val,
                              center.y + sin(angle) * r_val))
                              
        outer_points.append(Vector2(center.x + cos(angle) * radius,
                                    center.y + sin(angle) * radius))

    # Dibujar base del radar (polígono exterior)
    draw_polygon(outer_points, [Color(0.2, 0.2, 0.2, 0.4)])
    draw_polyline(outer_points + [outer_points[0]], Color(1,1,1,0.2), 1.0)
    
    # Dibujar polígono de métricas (el área azul)
    draw_polygon(points, [Color(0.2,0.8,1.0,0.5)])
    draw_polyline(points + [points[0]], Color(0.2,0.8,1.0), 2.0)
    
    # Dibujar líneas del centro a las esquinas
    for p in outer_points:
        draw_line(center, p, Color(1,1,1,0.25), 1.0)

    # dibujar imágenes clickeables
    label_rects.clear()
    for i in range(n):
        var dir = (outer_points[i] - center).normalized()
        var img = label_textures[i]

        var original_size = img.get_size()
        var scale_factor = 100.0 / max(original_size.x, original_size.y)
        var img_size = original_size * scale_factor

        var label_pos = outer_points[i] + dir * 25.0 - img_size / 2.0
        label_rects.append(Rect2(label_pos, img_size))
        draw_texture_rect(img, Rect2(label_pos, img_size), false)

func _gui_input(event):
    if event is InputEventMouseButton and event.pressed:
        for i in range(label_rects.size()):
            if label_rects[i].has_point(event.position):
                print("Clic en etiqueta: %s" % labels[i])

                # cambiar título y texto del panel
                label_title.text = labels[i]
                label_info_text.text = label_info[i]

                # ajustar visibilidad del panel
                _ajustar_panel_a_pantalla()

                # efecto visual opcional
                panel_info.modulate = Color(1, 1, 1, 1)

# 🟢 Función para mover el panel si se sale de la pantalla
func _ajustar_panel_a_pantalla() -> void:
    await get_tree().process_frame	# espera a que se actualice el tamaño del texto
    var viewport_rect = get_viewport_rect()
    var panel_rect = panel_info.get_global_rect()

    var offset_y = 0.0
    if panel_rect.end.y > viewport_rect.end.y:
        offset_y = viewport_rect.end.y - panel_rect.end.y - 20.0

    # mover suavemente el panel si se sale
    if offset_y != 0.0:
        panel_info.position.y += offset_y
