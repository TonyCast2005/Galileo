extends Control

@onready var usuario = $usuario
@onready var correo = $correo
@onready var contrasena = $"contrasena"
@onready var confirmar = $"confirmarContrasena"
@onready var mensaje = $Mensaje

var auth

func _ready():
    auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
    add_child(auth)


func _on_aceptar_pressed():

    # ================================
    # VALIDACIONES
    # ================================
    if usuario.text.is_empty() or correo.text.is_empty() or contrasena.text.is_empty():
        mensaje.text = "⚠️ Favor de llenar los campos"
        return

    if contrasena.text != confirmar.text:
        mensaje.text = "❌ Las contraseñas no coinciden"
        return

    if contrasena.text.length() < 8:
        mensaje.text = "❌ La contraseña debe tener mínimo 8 caracteres"
        return

    # ================================
    # OBTENER DATOS LIMPIOS
    # ================================
    var nombre = usuario.text.strip_edges()
    var email = correo.text.strip_edges().to_lower()
    var password = contrasena.text.strip_edges()

    # ================================
    # REGISTRAR EN FIREBASE AUTH
    # ================================
    var res = await auth.register_user(email, password, nombre)
    print("Resultado del registro:", res)

    if res.has("error"):
        mensaje.text = "❌ Error al registrar: %s" % res["error"]
        return

    var uid = res.get("localId", "")
    if uid == "":
        mensaje.text = "❌ Error obteniendo UID"
        return

    # ================================
    # PERFIL COMPLETO PARA FIREBASE DB
    # ================================
    var data_inicial = {
        "nombre": nombre,
        "email": email,
        "contrasena": password,
        "foto": "default",
        "nivel": "novato",

        "logros": {
            "primera_presa": null,
            "caja_carton": null,
            "pez_gordo": null,
            "experto_arduino": null,
            "el_minino_resiste": null,
            "gato_pwm": null,
            "leyenda_cable": null,
            "gato_velocista": null,
            "pelea_techo": null,
            "gatos_pardos": null,
            "aprendiz_veloz": null,
            "teorico_nato": null,
            "explorador_incansable": null,
            "aprendiz_visual": null,
            "cazador_bugs": null
        },

        "metrics": {},

        "progreso": {
            "nivel_actual": "novato",
            "leccion_actual": 0
        },

        "racha": {
            "dias": 0,
            "ultima_fecha": ""
        }
    }

    # ================================
    # GUARDAR PERFIL EN REALTIME DB
    # ================================
    var respuesta_db = await auth.update_user_data(uid, data_inicial)
    print("➡️ Datos creados en Firebase DB:", respuesta_db)

    # ================================
    # GUARDAR EN GLOBALS
    # ================================
    Globals.user = {
        "uid": uid,
        "email": email,
        "nombre": nombre,
        "nivel": "novato",
        "logros": data_inicial["logros"]
    }

    # ================================
    # CAMBIAR A LA ESCENA DEL TEST
    # ================================
    get_tree().change_scene_to_file("res://escenas/TestUbicacion/test1.tscn")


func _on_iniciarsesion_pressed():
    get_tree().change_scene_to_file("res://escenas/usuario/registro/iniciarSesion.tscn")
