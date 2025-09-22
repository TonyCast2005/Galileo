extends Control

@onready var panel_retro = $PanelRetroalimentacion
@onready var label_retro = $PanelRetroalimentacion/LabelRetroalimentacion
@onready var image_retro = $PanelRetroalimentacion/Galileo
@onready var color_rect = $PanelRetroalimentacion/ColorRect
@onready var boton_retro = $PanelRetroalimentacion/BotonSiguiente
@onready var contenedor_preguntas = $ContenedorPreguntas

signal siguiente_pregunta  # ✅ señal pública

# Ejemplo: cuando se presiona el botón de retroalimentación

var preguntas = [
    preload("res://escenas/Tipos_preguntas/OpcionMultiple/OpcionMultiple.tscn"),
]

var velocidad = 0.04
var frame_hablando = [
    preload("res://assets/sprites/ui/Galileo/Feli.png")
]
var frame_idle = preload("res://assets/sprites/ui/Galileo/Galileo Base.png")

var panel_activo = false
var indice_actual = 0
var instancia_actual = null
var ultima_correcta = false  # Guardamos si fue correcta o no

func _ready():
    panel_retro.visible = false
    cargar_pregunta(indice_actual)
    boton_retro.pressed.connect(_on_boton_retro_pressed)

# ---------------------------
# INSTANCIADO DE PREGUNTAS
# ---------------------------
func cargar_pregunta(indice: int):
    if instancia_actual:
        instancia_actual.queue_free()

    var escena = preload("res://escenas/Tipos_preguntas/OpcionMultiple/OpcionMultiple.tscn").instantiate()
    contenedor_preguntas.add_child(escena)
    instancia_actual = escena

    # Pasamos datos de la pregunta (desde Firebase o un array local)
    if instancia_actual.has_method("set_pregunta"):
        instancia_actual.set_pregunta(preguntas[indice])

    # Conectar señal respondida
    instancia_actual.respondida.connect(_on_pregunta_respondida)


# ---------------------------
# MANEJAR SEÑAL DE PREGUNTA
# ---------------------------
func _on_pregunta_respondida(texto: String, color: Color, correcta: bool):
    ultima_correcta = correcta
    mostrar_retroalimentacion(texto, color)

# ---------------------------
# BOTÓN DE RETROALIMENTACIÓN
# ---------------------------
func _on_boton_retro_pressed():
    emit_signal("siguiente_pregunta")
    cerrar_panel()

    if ultima_correcta:
        indice_actual += 1
        if indice_actual < preguntas.size():
            cargar_pregunta(indice_actual)   # 👈 aquí se cambia la pregunta
        else:
            label_retro.text = "🎉 Examen terminado"
            panel_retro.show()
            boton_retro.disabled = true

    else:
        # Si no fue correcta, solo cerramos el panel (sin avanzar)
        pass

# ---------------------------
# FUNCIÓN PRINCIPAL DE RETRO
# ---------------------------
func mostrar_retroalimentacion(texto: String, color: Color) -> void:
    if panel_activo:
        return
    panel_activo = true

    label_retro.text = ""
    label_retro.modulate = Color(1,1,1)
    color_rect.color = color
    panel_retro.visible = true
    image_retro.visible = true
    boton_retro.visible = false  # Oculto al iniciar
    boton_retro.disabled = true  # Deshabilitado al iniciar

    var viewport_size = get_viewport_rect().size
    var panel_altura = panel_retro.size.y
    var target_y = viewport_size.y - panel_altura
    var fuera_pantalla = viewport_size.y + panel_altura

    panel_retro.position.y = fuera_pantalla

    # Animación de entrada
    var tween = create_tween()
    tween.tween_property(panel_retro, "position:y", target_y, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

    await get_tree().create_timer(0.2).timeout

    # Animación de hablar y mover gato
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
    tween_gato.tween_property(image_retro, "position:y", pos_original.y - 8, 0.12)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween_gato.tween_property(image_retro, "position:y", pos_original.y, 0.12)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    # Escribir texto letra por letra
    for i in texto.length():
        label_retro.text += texto[i]
        await get_tree().create_timer(velocidad).timeout

    hablando = false
    image_retro.texture = frame_idle
    tween_gato.kill()
    image_retro.position = pos_original

    # Activar el botón solo después de escribir el texto
    boton_retro.visible = true
    boton_retro.disabled = false

# ---------------------------
# CERRAR PANEL
# ---------------------------
func cerrar_panel():
    var viewport_size = get_viewport_rect().size
    var panel_altura = panel_retro.size.y
    var fuera_pantalla = viewport_size.y + panel_altura

    var tween_out = create_tween()
    tween_out.tween_property(panel_retro, "position:y", fuera_pantalla, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween_out.tween_callback(func():
        panel_retro.hide()
        image_retro.hide()
        panel_activo = false
    )
