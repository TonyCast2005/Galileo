extends Control

@onready var usuario = $usuario
@onready var contrasena = $"contraseña"
@onready var mensaje = $Mensaje
var auth

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)

func _on_aceptar_pressed():
	if usuario.text.is_empty() or contrasena.text.is_empty():
		mensaje.text = "Favor de llenar los campos"
		print("Favor de llenar los campos")
		return

	var res = await auth.login_user(usuario.text, contrasena.text)
	if "error" in res:
		mensaje.text = "Credenciales incorrectas"
	else:
		mensaje.text = "Inicio de sesión exitoso"
		get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")
		var id_token = res["idToken"]
			
func _on_registrarse_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/registrarse.tscn")


func _on_reccontrasenna_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/RecuperarContrasena.tscn")
