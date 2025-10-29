extends Control

@onready var usuario = $usuario           
@onready var correo = $correo             
@onready var contrasena = $"contraseña" 
@onready var confirmar = $"confirmarContraseña" 
@onready var mensaje = $Mensaje

var auth
var crypto

func _ready():
	auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)
	#Cargar cifrador AES
	crypto = load("res://escenas/usuario/registro/crypto_manager.gd").new()
	add_child(crypto)

func _on_aceptar_pressed():
	if usuario.text.is_empty() or correo.text.is_empty() or contrasena.text.is_empty():
		mensaje.text = "Favor de llenar los campos"
		return
		
	if contrasena.text != confirmar.text:
		mensaje.text = "Las contraseñas no coinciden"
		return
	
	var email = correo.text.strip_edges().to_lower()
	var password = contrasena.text.strip_edges()
	var nombre = usuario.text.strip_edges()

	# Cifrar antes de enviar
	var encrypted_pass = crypto.encrypt_password(password)

	var res = await auth.register_user(email, encrypted_pass, nombre)
	print("Resultado del registro:", res)
	
	if res.has("error"):
		mensaje.text = "Error al registrar: %s" % res["error"]
		return

	Globals.user = {
		"uid": res.get("localId", ""),
		"email": res.get("email", ""),
		"nombre": nombre
	}

	get_tree().change_scene_to_file("res://escenas/TestUbicacion/test1.tscn")

func _on_iniciarsesion_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/registro/iniciarSesion.tscn")
