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

    # 🔹 Limpiar los textos antes de enviar a Firebase
    var email = correo.text.strip_edges().to_lower()
    var password = contrasena.text.strip_edges()
    var nombre = usuario.text.strip_edges()

    # 🔹 Llamar a la función de registro con los valores limpios
    var res = await auth.register_user(email, password, nombre)
    
    # 🔹 Mostrar el resultado en consola para depurar (puedes quitarlo luego)
    print("Resultado del registro:", res)
    
    if res.has("error"):
        mensaje.text = "❌ Error al registrar: %s" % res["error"]
        print("Respuesta completa Firebase:", JSON.stringify(res, "\t"))

        return

    # Guardar datos del usuario en Globals
    Globals.user = {
        "uid": res.get("localId", ""),
        "email": res.get("email", ""),
        "nombre": nombre
    }

    # Cambiar a la escena de perfil
    get_tree().change_scene_to_file("res://escenas/TestUbicacion/test1.tscn")


func _on_iniciarsesion_pressed():
    get_tree().change_scene_to_file("res://escenas/usuario/registro/iniciarSesion.tscn")
