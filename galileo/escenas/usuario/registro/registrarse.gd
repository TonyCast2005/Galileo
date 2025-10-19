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
	if usuario.text.is_empty() or contrasena.text.is_empty():
		mensaje.text = "Favor de llenar los campos"
		print("Favor de llenar los campos")
		return
		
	if contrasena.text != confirmar.text:
		mensaje.text = "Las contraseñas no coinciden"
		return

	var res = await auth.register_user(correo.text, contrasena.text)
	
	if not "error" in res:
	var uid = res["localId"]

	var user_data = {
		"email": email,
		"nombre": nombre_usuario.text,  # si tienes un campo de nombre
		"nivel": "principiante",
		"logros": {}
	}

	await auth.save_user_data(uid, user_data)
	print("✅ Usuario guardado en Firebase:", user_data)


	if "error" in res:
		mensaje.text = res.error.message
	else:
		mensaje.text = "Cuenta creada correctamente"
		get_tree().change_scene_to_file("res://escenas/TestUbicacion/test1.tscn")

func _on_iniciarsesion_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/iniciarSesion.tscn")
