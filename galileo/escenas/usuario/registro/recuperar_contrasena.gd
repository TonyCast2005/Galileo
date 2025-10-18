extends Control

@onready var correo = $ColorRect/correo
@onready var mensaje = $Mensaje
var auth

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)

func _on_recuperar_pressed():
	if correo.text.is_empty():
		mensaje.text = "Favor de llenar los campos"
		print("Favor ingresar el correo")
		return
		
	var res = await auth.recover_account(correo.text)
	if "error" in res:
		mensaje.text = res.error.message
	else:
		mensaje.text = "Se envió el correo :)"
		
func _on_registrarse_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/registrarse.tscn")

func _on_iniciarsesion_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/iniciarSesion.tscn")
