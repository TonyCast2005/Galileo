# gato_instrucciones.gd
extends Node2D

@export var dialogos: Array = []

signal tutorial_terminado

var indice = 0

func iniciar_tutorial():
    mostrar_siguiente_dialogo()

func mostrar_siguiente_dialogo():
    if indice < dialogos.size():
        $NinePatchRect/TextoInstrucciones.text = dialogos[indice]
        indice += 1
    else:
        emit_signal("tutorial_terminado")
        queue_free()
