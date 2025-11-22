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

	if usuario.text == "admin@gmail.com":
		get_tree().change_scene_to_file("res://escenas/Administrador/inicial.tscn")
		return

	mensaje.text = "🔄 Iniciando sesión..."

	var res = await auth.login_user(usuario.text, contrasena.text)
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

	# UID
	var uid = res.get("localId", "")

	# Obtener datos completos desde DB
	var db_data = await auth._get_user_data(uid)

	if db_data == null:
		mensaje.text = "⚠️ No se pudieron cargar los datos del usuario"
		return

	# Guardar todo en Globals.user
	Globals.user = {
		"idToken": res.get("idToken", ""),
		"uid": uid,
		"email": usuario.text,
		"nombre": db_data.get("nombre", "Usuario"),
		"foto": db_data.get("foto", "default"),
		"nivel": db_data.get("nivel", "novato"),
		"logros": db_data.get("logros", {}),
		"metrics": db_data.get("metrics", {}),
		"progreso": db_data.get("progreso", {}),
		"racha": db_data.get("racha", {})
	}

	print("📦 Datos cargados en Globals.user:", Globals.user)

	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")


func _on_registrarse_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/registrarse.tscn")
