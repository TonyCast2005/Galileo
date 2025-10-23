extends Control

@onready var novato = $ColorRect/Novato
@onready var raiz = $ControlGato
@onready var competente = $ColorRect/Competente
@onready var experimentado = $ColorRect/Experimentado

var instancia_actual

func _on_button_pressed():
    var escena = preload("res://escenas/TestUbicacion/explicacion.tscn").instantiate()
    raiz.add_child(escena)
    instancia_actual = escena

func _on_competente_pressed():
    pass

func _on_experimentado_pressed():
    pass
