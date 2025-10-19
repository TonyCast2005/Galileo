extends Control

@onready var novato = $ColorRect/Novato
@onready var raiz = $ControlGato
@onready var competente = $ColorRect/Competente
@onready var experimentado = $ColorRect/Experimentado

var instancia_actual

func _on_novato_pressed():
	pass # Replace with function body.
	
func _on_competente_pressed():
	pass

func _on_experimentado_pressed():
	pass
	
func _on_test_pressed():
	get_tree().change_scene_to_file("res://escenas/TestUbicacion/preambulo.tscn")
