extends Control

@onready var usuario = $usuario
@onready var correo = $correo
@onready var contrasena = $"contraseña"
@onready var confirmar = $"confirmarContraseña"
@onready var mensaje = $Mensaje

var auth

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)

func _on_aceptar_pressed():
	# Validar campos vacíos
	if usuario.text.is_empty() or correo.text.is_empty() or contrasena.text.is_empty() or confirmar.text.is_empty():
		mensaje.text = "⚠️ Favor de llenar todos los campos"
		print("Campos vacíos detectados")
		return
		
	# Validar contraseñas iguales
	if contrasena.text != confirmar.text:
		mensaje.text = "❌ Las contraseñas no coinciden"
		return

	# Limpiar valores antes de enviar
	var email = correo.text.strip_edges().to_lower()
	var password = contrasena.text.strip_edges()
	var nombre = usuario.text.strip_edges()

	# Registrar usuario (debe tener 3 argumentos)
	var res = await auth.register_user(email, password, nombre)

	# Revisar si hubo error
	if res.has("error"):
		mensaje.text = "❌ Error al registrar: %s" % res["error"]
		print("Error al registrar:", res)
		return
	
	# Obtener UID del usuario
	var uid = res.get("localId", "")
	if uid == "":
		mensaje.text = "⚠️ No se pudo obtener el ID del usuario."
		return

	# Guardar datos adicionales en Firebase Realtime Database
	var user_data = {
		"email": email,
		"nombre": nombre,
		"nivel": "principiante",  # puedes cambiarlo tras el test
		"logros": {}
	}

	var save_res = await auth.save_user_data(uid, user_data)
	if save_res.has("error"):
		mensaje.text = "⚠️ Usuario creado, pero error al guardar datos."
		print("Error al guardar en DB:", save_res)
	else:
		mensaje.text = "✅ Registro exitoso"
		print("Usuario registrado y guardado correctamente")

	# Guardar en Global (si usas un singleton)
	if Engine.has_singleton("Global"):
		Global.user_uid = uid
		Global.user_data = user_data

	# Cambiar de escena (solo una vez)
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")


func _on_iniciarsesion_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/iniciarSesion.tscn")
