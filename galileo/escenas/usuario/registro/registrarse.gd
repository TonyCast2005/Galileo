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
	if usuario.text.is_empty() or correo.text.is_empty() or contrasena.text.is_empty():
		mensaje.text = "Favor de llenar los campos"
		return
		
	if contrasena.text != confirmar.text:
		mensaje.text = "Las contraseñas no coinciden"
		return

	# ✅ Aquí solo se pasan los dos parámetros correctos
	var res = await auth.register_user(correo.text, contrasena.text, usuario.text)

	if "error" in res:
		mensaje.text = res.error.message
	else:
		var uid = res["localId"]
		var user_data = {
			"email": correo.text,
			"nombre": usuario.text, 
			"nivel": "principiante",
			"logros": {}
		}
		await auth.save_user_data(uid, user_data)

		Global.user_uid = uid
		Global.user_data = user_data

		get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")

func _on_iniciarsesion_pressed():
	get_tree().change_scene_to_file("res://escenas/TestUbicacion/test1.tscn")
