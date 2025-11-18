extends Control

@onready var actual = $Ventana/Actual
@onready var nuevo = $Ventana/Nuevo
@onready var confirmar = $Ventana/Confirmar
@onready var guardar = $Ventana/Guardar
@onready var mensaje = $Ventana/Mensaje   # Si no existe, dímelo

func _ready():
    # Asegurar que todos los campos de contraseña sean secretos
    
    nuevo.secret = true
    confirmar.secret = true

   

func _on_button_pressed() -> void:
    queue_free()


func _on_guardar_pressed() -> void:
    var pass_actual = actual.text.strip_edges()
    var pass_nueva = nuevo.text.strip_edges()
    var pass_conf = confirmar.text.strip_edges()

    # ----------------------------
    # Validaciones básicas
    # ----------------------------
    if pass_actual == "" or pass_nueva == "" or pass_conf == "":
        mensaje.text = "⚠️ Completa todos los campos"
        return

    if pass_nueva.length() < 6:
        mensaje.text = "🔐 La nueva contraseña debe tener al menos 6 caracteres"
        return

    if pass_nueva != pass_conf:
        mensaje.text = "❌ Las contraseñas nuevas no coinciden"
        return

    mensaje.text = "🔄 Verificando contraseña..."

    # ----------------------------
    # 1) Verificar contraseña actual haciendo login de nuevo
    # ----------------------------
    var auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
    add_child(auth)

    var email = Globals.user.get("email", "")
    var login = await auth.login_user(email, pass_actual)

    if login.has("error"):
        mensaje.text = "❌ La contraseña actual es incorrecta"
        return

    mensaje.text = "🔄 Actualizando contraseña..."

    # ----------------------------
    # 2) Actualizar contraseña en Firebase Authentication
    # ----------------------------
    var id_token = login.get("idToken", "")
    var api_key = auth.API_KEY

    var url = "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s" % api_key
    var data = {
        "idToken": id_token,
        "password": pass_nueva,
        "returnSecureToken": true
    }

    var http := HTTPRequest.new()
    add_child(http)

    var json = JSON.stringify(data)
    var headers = ["Content-Type: application/json"]

    var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
    if err != OK:
        mensaje.text = "❌ Error al enviar actualización"
        return

    var res = await http.request_completed
    var status = res[0]
    var code = res[1]
    var body = res[3]

    if code != 200:
        mensaje.text = "❌ Error al actualizar contraseña"
        return

    mensaje.text = "✅ Contraseña actualizada correctamente"

    # ----------------------------
    # 3) Cerrar ventana después de un segundo
    # ----------------------------
    await get_tree().create_timer(1.0).timeout
    queue_free()
