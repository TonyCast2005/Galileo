extends Control

@onready var correo = $Correo
@onready var mensaje = $Mensaje
var auth

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)

func _on_recuperar_pressed():
	var res = await auth.recover_account(correo.text)
	if "error" in res:
		mensaje.text = res.error.message
	else:
		mensaje.text = "Se envió e correo :)"
