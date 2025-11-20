extends Control

@onready var label = $NinePatchRect/TextoInstrucciones
@onready var gato = $Sprite2D
@onready var boton = $Button

var instrucciones: Array = []
var indice = 0
var velocidad = 0.044
var tween_habla: Tween = null
var tween_idle: Tween = null
var escribiendo = false
var dialogos_terminados = false

func _ready():
   
	animar_idle(true)
	if instrucciones.size() > 0:
		mostrar_instruccion()
	else:
		label.text = "¡Hola! No hay instrucciones definidas."


func set_instrucciones(nuevas_instrucciones: Array):
	instrucciones = nuevas_instrucciones
	indice = 0
	dialogos_terminados = false
	mostrar_instruccion()

func mostrar_instruccion():
	if indice < instrucciones.size():
		escribir_texto(instrucciones[indice])
	else:
		label.text = "¡Listo! Pulsa el botón para continuar."
		dialogos_terminados = true
		boton.show()

func escribir_texto(texto: String) -> void:
	label.text = ""
	escribiendo = true
  
	
	animar_idle(false)
	animar_habla(true)
	
	for i in texto.length():
		label.text += texto[i]
		await get_tree().create_timer(velocidad).timeout

	animar_habla(false)
	escribiendo = false
	boton.show()
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

func _on_comenzar_pressed():
	if dialogos_terminados:
		# Aquí puedes poner la escena siguiente
		print("Diálogos terminados, continuar...")
	else:
		mostrar_instruccion()


func _on_seguir_viendo_pressed() -> void:
	# Solo mostramos la siguiente instrucción si no está escribiendo
	if not escribiendo:
		mostrar_instruccion()


func _on_me_identifico_pressed() -> void:
	if dialogos_terminados:
		get_tree().change_scene_to_file("res://escenas/TestUbicacion/Examen.tscn")
	else:
		mostrar_instruccion()
