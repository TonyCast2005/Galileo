extends Control

@onready var panel_retro = $PanelRetroalimentacion
@onready var label_retro = $PanelRetroalimentacion/LabelRetroalimentacion
@onready var image_retro = $PanelRetroalimentacion/Galileo
@onready var color_rect = $PanelRetroalimentacion/ColorRect
@onready var boton_retro = $PanelRetroalimentacion/BotonSiguiente
@onready var contenedor_preguntas = $ContenedorPreguntas

var preguntas = [
    preload("res://escenas/Tipos_preguntas/OpcionMultiple.tscn"),
]

var velocidad = 0.04
var frame_hablando = [
    preload("res://assets/sprites/ui/Galileo/Feli.png")
]
var frame_idle = preload("res://assets/sprites/ui/Galileo/Galileo Base.png")

var panel_activo = false
var indice_actual = 0
var instancia_actual = null

func _ready():
    panel_retro.visible = false
    cargar_pregunta(indice_actual)

# ---------------------------
# INSTANCIADO DE PREGUNTAS
# ---------------------------
func cargar_pregunta(indice: int):
    if instancia_actual:
        instancia_actual.queue_free()
    var escena = preguntas[indice].instantiate()
    contenedor_preguntas.add_child(escena)
    instancia_actual = escena

# ---------------------------
# FUNCIONES DE LOS BOTONES DE RESPUESTA
# ---------------------------
func _on_positiva_pressed() -> void:
    mostrar_retroalimentacion("✅ ¡Muy bien! Has acertado.", Color(0,1,0))

func _on_negativa_pressed() -> void:
    mostrar_retroalimentacion("❌ Incorrecto... inténtalo otra vez.", Color(1,0,0))

func _on_pista_pressed() -> void:
    mostrar_retroalimentacion("💡 Pista: recuerda revisar el código del ejemplo.", Color(1,1,0))

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

    await get_tree().create_timer(1.5).timeout

    # Salida
    var tween_out = create_tween()
    tween_out.tween_property(panel_retro, "position:y", fuera_pantalla, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween_out.tween_callback(func():
        panel_retro.hide()
        image_retro.hide()
        panel_activo = false
    )
