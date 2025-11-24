extends Control

@onready var ok = $Ventana/Ok
@onready var gato = $Ventana/Sprite2D
@onready var texto_pista = $Ventana/NinePatchRect/TextoInstrucciones

var velocidad := 0.04
var tween_habla: Tween = null
var tween_idle: Tween = null
var escribiendo := false

var texto_final := "hola como estas esta es un apista galileo espero que a todos les guste este proyecto "   # ← La pista que se va a mostrar

func _ready():
    ok.hide()
    animar_idle(true)

    if texto_final != "":
        escribir_texto(texto_final)

# ---------------------------------------
# Llamar esta función desde otra escena
# para enviar la pista
# ---------------------------------------
func set_pista(texto: String) -> void:
    texto_final = texto

# ---------------------------------------
# Escritura tipo máquina
# ---------------------------------------
func escribir_texto(texto: String) -> void:
    texto_pista.text = ""
    escribiendo = true
    ok.hide()

    animar_idle(false)
    animar_habla(true)

    for i in texto.length():
        texto_pista.text += texto[i]
        await get_tree().create_timer(velocidad).timeout

    animar_habla(false)
    animar_idle(true)
    escribiendo = false
    ok.show()

# ---------------------------------------
# Animación de hablar
# ---------------------------------------
func animar_habla(habla: bool):
    if habla:
        gato.texture = preload("res://assets/sprites/ui/Galileo/Galileo Hablando 1.png")
        tween_habla = create_tween().set_loops()
        tween_habla.tween_property(gato, "position:y", gato.position.y + 3, 0.1)
        tween_habla.tween_property(gato, "position:y", gato.position.y, 0.1)
    else:
        gato.texture = preload("res://assets/sprites/ui/Galileo/Feli.png")
        if tween_habla:
            tween_habla.kill()
            tween_habla = null

# ---------------------------------------
# Animación idle
# ---------------------------------------
func animar_idle(activo: bool):
    if activo:
        if tween_idle:
            tween_idle.kill()
        tween_idle = create_tween().set_loops()
        tween_idle.tween_property(gato, "rotation_degrees", 5, 1)
        tween_idle.tween_property(gato, "rotation_degrees", -5, 2)
        tween_idle.tween_property(gato, "rotation_degrees", 0, 1)
    else:
        if tween_idle:
            tween_idle.kill()
            tween_idle = null
        gato.rotation_degrees = 0




func _on_ok_pressed() -> void:
    queue_free() 
