extends Control

@onready var usuario = $ColorRect/ColorRect2/usuario
@onready var contrasena = $"ColorRect/ColorRect2/contraseña"
@onready var mensaje = $ColorRect/Mensaje
@onready var Gato = $ColorRect/Gato
var auth

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)
	animar_gato()

func animar_gato():
	var tween := create_tween()
	var pos_inicial = Gato.position
	var desplazamiento = Vector2(10, 0)
	tween.tween_property(Gato, "position", pos_inicial + desplazamiento, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(Gato, "position", pos_inicial - desplazamiento, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()

func _on_aceptar_pressed():
	if usuario.text.is_empty() or contrasena.text.is_empty():
		mensaje.text = "⚠️ Favor de llenar los campos"
		return

	mensaje.text = "🔄 Iniciando sesión..."
	var res = await auth.login_user(usuario.text, contrasena.text)
	print("📩 Respuesta Firebase:", res)

	if res.has("error"):
		var msg = res["error"].get("message", "Error desconocido")

		match msg:
			"INVALID_LOGIN_CREDENTIALS", "INVALID_PASSWORD":
				mensaje.text = "❌ Credenciales incorrectas"
			"EMAIL_NOT_FOUND":
				mensaje.text = "❌ Correo no registrado"
			_:
				mensaje.text = "❌ Error: %s" % msg
		return

	# ✅ Inicio de sesión exitoso
	mensaje.text = "✅ Inicio de sesión exitoso"
	print("Login exitoso:", usuario.text)

	# Obtener información adicional del usuario
	var uid = res.get("localId", "")
	var nombre = "Usuario sin nombre"
	if uid != "":
		var extra_data = await auth._get_user_data(uid)
		if extra_data != null:
			nombre = extra_data.get("nombre", "Usuario sin nombre")

	# Guardar datos globales
	Globals.user = {
		"idToken": res.get("idToken", ""),
		"uid": uid,
		"email": usuario.text,
		"nombre": nombre
	}

	# 🧩 Guardar sesión localmente (encriptada)
	var session = load("res://scripts/session_manager.gd").new()
	session.save_session(
		res.get("idToken", ""),
		res.get("refreshToken", ""),
		usuario.text,
		res.get("localId", "")
	)

	# Cambiar a perfil
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")


func _on_registrarse_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/registrarse.tscn")


func _on_reccontrasenna_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/RecuperarContrasena.tscn")
