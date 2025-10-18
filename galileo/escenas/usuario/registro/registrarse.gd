extends Control

@onready var usuario = $usuario
@onready var correo = $correo
@onready var contrasena = $contraseña
@onready var confirmar = $"confirmarContraseña"
@onready var mensaje = $Mensaje

var auth

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)


	
func _on_aceptar_pressed():
	if contrasena.text != confirmar.text:
		mensaje.text = "Las contraseñas no coinciden"
		return

	var res = await auth.register_user(correo.text, contrasena.text)
	if "error" in res:
		mensaje.text = res.error.message
	else:
		mensaje.text = "Cuenta creada correctamente"
		get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")

func _on_iniciarsesion_pressed():
	print("✅ Botón presionado correctamente")
	var path = "res://escenas/usuario/registro/iniciarSesion.tscn"
	var error = get_tree().change_scene_to_file(path)
	print("Resultado:", error)
