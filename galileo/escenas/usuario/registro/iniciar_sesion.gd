extends Control

@onready var usuario = $ColorRect/ColorRect2/usuario
@onready var contrasena = $"ColorRect/ColorRect2/contraseña"
@onready var mensaje = $ColorRect/Mensaje
@onready var Gato = $ColorRect/Gato

var auth
var crypto

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)

	#Cargar cifrador AES
	crypto = load("res://crypto_manager.gd").new()
	add_child(crypto)

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
	
	#Cifrar contraseña antes de enviar
	var encrypted_pass = crypto.encrypt_password(contrasena.text)

	var res = await auth.login_user(usuario.text, encrypted_pass)
	print("📩 Respuesta Firebase:", res)

	if res.has("error"):
		var msg = res["error"].get("message", "Error desconocido")
		if msg == "INVALID_LOGIN_CREDENTIALS":
			mensaje.text = "❌ Credenciales incorrectas"
		elif msg == "EMAIL_NOT_FOUND":
			mensaje.text = "❌ Correo no registrado"
		elif msg == "INVALID_PASSWORD":
			mensaje.text = "❌ Contraseña incorrecta"
		else:
			mensaje.text = "❌ Error: %s" % msg
		return

	mensaje.text = "✅ Inicio de sesión exitoso"
	print("Login exitoso:", usuario.text)

	var uid = res.get("localId", "")
	var nombre = "Usuario sin nombre"
	if uid != "":
		var extra_data = await auth._get_user_data(uid)
		if extra_data != null:
			nombre = extra_data.get("nombre", "Usuario sin nombre")

	Globals.user = {
		"idToken": res.get("idToken", ""),
		"uid": uid,
		"email": usuario.text,
		"nombre": nombre
	}

	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")
