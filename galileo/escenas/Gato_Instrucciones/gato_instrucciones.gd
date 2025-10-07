# gato_instrucciones.gd
extends Control

@export var dialogos: Array = []
signal tutorial_terminado

var indice = 0

func _ready():
    # Centra el control en pantalla
    anchor_left = 0.5
    anchor_top = 0.5
    anchor_right = 0.5
    anchor_bottom = 0.5
    offset_left = -size.x / 2
    offset_top = -size.y / 2
    offset_right = size.x / 2
    offset_bottom = size.y / 2

func iniciar_tutorial():
    mostrar_siguiente_dialogo()

func mostrar_siguiente_dialogo():
    if indice < dialogos.size():
        $NinePatchRect/TextoInstrucciones.text = dialogos[indice]
        indice += 1
    else:
        emit_signal("tutorial_terminado")
        queue_free()
