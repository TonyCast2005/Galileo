extends Control

@onready var novato = $ColorRect/btn_novato
@onready var raiz = $ControlGato
@onready var competente = $ColorRect/btn_competente
@onready var experimentado = $ColorRect/btn_experimentado
@onready var ventana = $VentanaDefinicion
@onready var texto_definicion = $VentanaDefinicion/TextoDefinicion
@onready var btn_aceptar = $VentanaDefinicion/BtnAceptar
@onready var btn_seguir = $VentanaDefinicion/BtnSeguir
var auth
var instancia_actual

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)
	ventana.visible = false

	btn_aceptar.pressed.connect(_on_aceptar_pressed)
	btn_seguir.pressed.connect(_on_seguir_pressed)

func _on_novato_pressed():
	print("novato")
	_mostrar_definicion("Conceptos muy generales o acabas de comenzar con tu aprendizaje.", "novato")
	
func _on_competente_pressed():
	print("comp")
	_mostrar_definicion("Conocimiento básico de C y Arduino, entendimiento de variables, condicionales, ciclos y funciones.", "competente")

func _on_experimentado_pressed():
	print("exp")
	_mostrar_definicion("Dominio del lenguaje C y su lógica de programación, manejo de interrupciones, comunicación serial, librerías, sensores y actuadores.", "experimentado")
	
func _on_test_pressed():
	print("test")
	get_tree().change_scene_to_file("res://escenas/TestUbicacion/preambulo.tscn")

func _mostrar_definicion(texto: String, nivel: String):
	texto_definicion.text = texto
	ventana.set_meta("nivel", nivel) 
	ventana.visible = true

func _on_aceptar_pressed():
	var nivel = ventana.get_meta("nivel")
	ventana.visible = false
	print("aceptar nivel:", nivel)

	# 🔥 Obtener el uid del usuario actual
	var uid = Globals.user.get("uid", "")

	# 🔥 Datos a actualizar
	var data_actualizar = {
		"nivel": nivel
	}

	# 🔥 Guardar en Firebase Database
	var res = await auth.update_user_data(uid, data_actualizar)
	print("Firebase nivel actualizado:", res)

	# 🔥 Actualizar Globals
	Globals.user["nivel"] = nivel

	# Cambiar escena
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")

	

func _on_seguir_pressed():
	ventana.visible = false
