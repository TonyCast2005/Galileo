extends Control

@onready var usuario = $usuario            # LineEdit del nombre
@onready var correo = $correo              # LineEdit del correo
@onready var contrasena = $"contraseña"   # LineEdit de la contraseña
@onready var confirmar = $"confirmarContraseña"  # LineEdit de confirmación
@onready var mensaje = $Mensaje

var auth

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)


func _on_aceptar_pressed():
	# Validar campos vacíos
	if usuario.text.is_empty() or correo.text.is_empty() or contrasena.text.is_empty():
		mensaje.text = "⚠️ Favor de llenar los campos"
		return
		
	# Validar que las contraseñas coincidan
	if contrasena.text != confirmar.text:
		mensaje.text = "❌ Las contraseñas no coinciden"
		return

	# 🔹 Limpiar datos
	var email = correo.text.strip_edges().to_lower()
	var password = contrasena.text.strip_edges()
	var nombre = usuario.text.strip_edges()

	# 🔹 Registrar usuario en Firebase Authentication
	var res = await auth.register_user(email, password, nombre)
	print("Resultado del registro:", res)
	
	if res.has("error"):
		mensaje.text = "❌ Error al registrar: %s" % res["error"]
		print("Respuesta completa Firebase:", JSON.stringify(res, "\t"))
		return

	# 🔥 **UID único del usuario**
	var uid = res.get("localId", "")

	# -------------------------------------------------------------------------
	# ✅ **CREAR PERFIL DEL USUARIO EN REALTIME DATABASE**
	# -------------------------------------------------------------------------
	var data_inicial = {
		"nombre": nombre,
		"email": email,
		"foto": "default",         # foto de perfil inicial
		"nivel": "novato",         # nivel inicial por defecto
		"logros": {},              # carpeta para guardar logros
		"metrics": {},             # carpeta para métricas
		"progreso": {
			"nivel_actual": "novato",
			"leccion_actual": 0
		},
		"racha": {
			"dias": 0,
			"ultima_fecha": ""
		}
	}

	var respuesta_db = await auth.update_user_data(uid, data_inicial)
	print("➡️ Datos creados en Firebase DB:", respuesta_db)
	# -------------------------------------------------------------------------

	# Guardar datos básicos en Globals
	Globals.user = {
		"uid": uid,
		"email": email,
		"nombre": nombre
	}

	# Cambiar a la escena del Test
	get_tree().change_scene_to_file("res://escenas/TestUbicacion/test1.tscn")


func _on_iniciarsesion_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/iniciarSesion.tscn")
