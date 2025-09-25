extends Control
@onready var texto = $NinePatchRect/Texto
@onready var gato = $Galileo
@onready var overlay = $ColorRect
var velocidad = 0.04
var frame_hablando = [
    preload("res://assets/sprites/ui/Galileo/Feli.png")
]
var frame_idle = preload("res://assets/sprites/ui/Galileo/Galileo Base.png")

var instrucciones = [
    "¡Hola! Soy Galileo 🐱 tu guía.",
    "En este ejercicio verás un código con errores.",
    "Debes hacer clic en la parte incorrecta.",
    "Si aciertas, podrás corregirlo escribiendo.",
    "¡Vamos a intentarlo! 😺"
]

var indice = 0
var hablando = false
func _ready():
    overlay.color = Color(0, 0, 0, 0.6)  # negro con alpha 0.6

    mostrar_instruccion()


func mostrar_instruccion():
    texto.text = ""
    var mensaje = instrucciones[indice]

    # animación de hablar
    hablando = true
    var cambio_boca = 0
    var boca_timer = get_tree().create_timer(velocidad * 3, true)
    boca_timer.timeout.connect(func():
        if hablando:
            gato.texture = frame_hablando[cambio_boca % frame_hablando.size()]
            cambio_boca += 1
    )

    # animación de rebotito del gato
    var pos_original = gato.position
    var tween_gato = create_tween().set_loops()
    tween_gato.tween_property(gato, "position:y", pos_original.y - 8, 0.10)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween_gato.tween_property(gato, "position:y", pos_original.y, 0.1)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    # escribir letra por letra
    await escribir_texto(mensaje)

    # cuando termina
    hablando = false
    gato.texture = frame_idle
    tween_gato.kill()
    gato.position = pos_original


func escribir_texto(mensaje: String) -> void:
    for i in mensaje.length():
        texto.text += mensaje[i]
        await get_tree().create_timer(velocidad).timeout


func _unhandled_input(event):
    if Input.is_action_just_pressed("tap_pantalla") and not hablando:
        indice += 1
        if indice < instrucciones.size():
            mostrar_instruccion()
        else:
            hide()  # Termina tutorial
