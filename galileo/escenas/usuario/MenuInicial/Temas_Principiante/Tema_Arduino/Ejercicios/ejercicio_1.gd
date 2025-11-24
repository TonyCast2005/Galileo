extends Control

@onready var panel_retro = $PanelRetroalimentacion
@onready var label_retro = $PanelRetroalimentacion/LabelRetroalimentacion
@onready var image_retro = $PanelRetroalimentacion/Galileo
@onready var color_rect = $PanelRetroalimentacion/ColorRect
@onready var boton_retro = $PanelRetroalimentacion/BotonSiguiente
@onready var contenedor_preguntas = $ContenedorPreguntas
@onready var progreso = $Progreso
@onready var http = $HTTPRequest  

var preguntas: Array = []
var indice_actual = 0
var instancia_actual = null
var panel_activo = false
var velocidad = 0.04
var frame_hablando = [ preload("res://assets/sprites/ui/Galileo/Feli.png") ]
var frame_idle = preload("res://assets/sprites/ui/Galileo/Galileo Base.png")

# Nodo que maneja el desbloqueo
var menu_nivel = null  # asignar desde la escena padre (MenuTema1)

func _ready():
    http.request_completed.connect(_on_request_completed)
    http.request("https://galileo-af640-default-rtdb.firebaseio.com/examen_ubicacion.json")
    boton_retro.pressed.connect(_on_boton_retro_pressed)

func _on_request_completed(result, response_code, headers, body):
    if response_code == 200:
        var data = JSON.parse_string(body.get_string_from_utf8())
        preguntas = data if typeof(data) == TYPE_ARRAY else data.values()

        if preguntas.size() > 0:
            cargar_pregunta(indice_actual)
        else:
            label_retro.text = " No hay preguntas disponibles"
            panel_retro.show()
    else:
        label_retro.text = " Error al cargar preguntas"
        panel_retro.show()

func cargar_pregunta(indice: int):
    if instancia_actual:
        instancia_actual.queue_free()
    var escena = preload("res://escenas/Tipos_preguntas/OpcionMultiple/OpcionMultiple.tscn").instantiate()
    contenedor_preguntas.add_child(escena)
    instancia_actual = escena

    var pregunta = preguntas[indice]
    if instancia_actual.has_method("set_pregunta"):
        instancia_actual.set_pregunta(pregunta)

    if instancia_actual.has_signal("respondida") and not instancia_actual.is_connected("respondida", _on_pregunta_respondida):
        instancia_actual.respondida.connect(_on_pregunta_respondida)

func _on_pregunta_respondida(texto: String, color: Color, correcta: bool):
    mostrar_retroalimentacion(texto, color)
    boton_retro.visible = true
    boton_retro.disabled = false

func _on_boton_retro_pressed():
    cerrar_panel()
    indice_actual += 1
    progreso.text = "Pregunta " + str(indice_actual + 1)

    if indice_actual < preguntas.size():
        cargar_pregunta(indice_actual)
    else:
        # ✅ Al terminar todas las preguntas, desbloquea el siguiente nivel
        if menu_nivel:
            menu_nivel.desbloquear_siguiente()
        get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")

func mostrar_retroalimentacion(texto: String, color: Color) -> void:
    if panel_activo: return
    panel_activo = true

    label_retro.text = ""
    color_rect.color = color
    panel_retro.visible = true
    image_retro.visible = true
    boton_retro.visible = false
    boton_retro.disabled = true

    var viewport_size = get_viewport_rect().size
    var panel_altura = panel_retro.size.y
    var target_y = viewport_size.y - panel_altura
    panel_retro.position.y = viewport_size.y + panel_altura

    var tween = create_tween()
    tween.tween_property(panel_retro, "position:y", target_y, 0.4)

    await get_tree().create_timer(0.2).timeout

    var hablando = true
    var cambio_boca = 0
    var boca_timer = get_tree().create_timer(velocidad * 2, true)
    boca_timer.timeout.connect(func():
        if hablando:
            image_retro.texture = frame_hablando[cambio_boca % frame_hablando.size()]
            cambio_boca += 1
    )

    var pos_original = image_retro.position
    var tween_gato = create_tween().set_loops()
    tween_gato.tween_property(image_retro, "position:y", pos_original.y - 8, 0.12)
    tween_gato.tween_property(image_retro, "position:y", pos_original.y, 0.12)

    for i in texto.length():
        label_retro.text += texto[i]
        await get_tree().create_timer(velocidad).timeout

    hablando = false
    image_retro.texture = frame_idle
    tween_gato.kill()
    image_retro.position = pos_original

    boton_retro.visible = true
    boton_retro.disabled = false

func cerrar_panel():
    var viewport_size = get_viewport_rect().size
    var panel_altura = panel_retro.size.y
    var tween_out = create_tween()
    tween_out.tween_property(panel_retro, "position:y", viewport_size.y + panel_altura, 0.5)
    tween_out.tween_callback(func():
        panel_retro.hide()
        image_retro.hide()
        panel_activo = false)
