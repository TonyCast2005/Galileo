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
		return

	mensaje.text = "Iniciando sesión..."
	var res = await auth.login_user(usuario.text, contrasena.text)
	print("Respuesta Firebase:", res)

	if res.has("error"):
		var msg = res["error"].get("message", "Error desconocido")

		if msg == "INVALID_LOGIN_CREDENTIALS":
			mensaje.text = "Credenciales incorrectas"
		elif msg == "EMAIL_NOT_FOUND":
			mensaje.text = "Correo no registrado"
		elif msg == "INVALID_PASSWORD":
			mensaje.text = "Contraseña incorrecta"
		elif msg == "INVALID_EMAIL":
			mensaje.text = "Correo incorrecto"
		else:
			mensaje.text = "Error: %s" % msg

		return

	mensaje.text = "Inicio de sesión exitoso"
	print("Login exitoso:", usuario.text)

	var uid = res.get("localId", "")
	Global.user_uid = uid

	var user_data = await auth.get_user_data(uid)
	if user_data.has("error"):
		mensaje.text = "No se pudieron cargar los datos del perfil"
		Global.user_data = {"email": usuario.text}
	else:
		Global.user_data = user_data

	print("Datos cargados:", Global.user_data)

	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")

func _on_registrarse_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/registrarse.tscn")

func _on_reccontrasenna_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/RecuperarContrasena.tscn")
