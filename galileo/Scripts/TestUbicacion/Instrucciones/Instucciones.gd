extends Node2D

@onready var label = $NinePatchRect/TextoInstrucciones
@onready var gato = $Sprite2D
@onready var boton = $comenzar

var instrucciones = [
    "¡Hola! Soy tu gato guía 😺.",
    "En este examen tendrás 10 preguntas.",
    "Tienes 15 minutos para responder.",
    "¡Haz tu mejor esfuerzo y mucha suerte!"
]

var indice = 0
var velocidad = 0.044
var tween_habla: Tween = null
var tween_idle: Tween = null
var escribiendo = false
var dialogos_terminados = false

func _ready():
    boton.hide()
    animar_idle(true)  # Activar movimiento idle al inicio
    mostrar_instruccion()

func mostrar_instruccion():
    if indice < instrucciones.size():
        escribir_texto(instrucciones[indice])
    else:
        label.text = "¡Listo! Pulsa el botón para comenzar el examen."
        dialogos_terminados = true
        boton.show()

func escribir_texto(texto: String) -> void:
    label.text = ""
    escribiendo = true
    boton.hide()

    # Desactivar idle mientras habla
    animar_idle(false)
    
    # Activar animación de hablar
    animar_habla(true)
    
    for i in texto.length():
        label.text += texto[i]
        await get_tree().create_timer(velocidad).timeout

    # Termina la animación
    animar_habla(false)
    escribiendo = false
    boton.show()

    # Reactivar idle cuando no habla
    animar_idle(true)
    indice += 1

func animar_habla(habla: bool):
    if habla:
        gato.texture = preload("res://assets/sprites/ui/Galileo/Galileo Hablando 1.png")
        tween_habla = create_tween()
        tween_habla.set_loops()
        tween_habla.tween_property(gato, "position:y", gato.position.y + 3, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        tween_habla.tween_property(gato, "position:y", gato.position.y, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    else:
        gato.texture = preload("res://assets/sprites/ui/Galileo/Feli.png")
        if tween_habla:
            tween_habla.kill()
            tween_habla = null

# Animación idle: ligera rotación izquierda-derecha
func animar_idle(activo: bool):
    if activo:
        if tween_idle:
            tween_idle.kill()
        tween_idle = create_tween()
        tween_idle.set_loops()
        tween_idle.tween_property(gato, "rotation_degrees", 5, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        tween_idle.tween_property(gato, "rotation_degrees", -5, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        tween_idle.tween_property(gato, "rotation_degrees", 0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    else:
        if tween_idle:
            tween_idle.kill()
            tween_idle = null
        gato.rotation_degrees = 0

# Función conectada al botón
func _on_comenzar_pressed():
    if dialogos_terminados:
        get_tree().change_scene_to_file("res://escenas/TestUbicacion/Examen.tscn")
    else:
        mostrar_instruccion()
