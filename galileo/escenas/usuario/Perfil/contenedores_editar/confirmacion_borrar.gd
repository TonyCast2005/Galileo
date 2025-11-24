extends Control

@onready var boton_eliminar = $Ventana/BtnEliminar
@onready var input_usuario = $Ventana/Input
@onready var label_error = $Ventana/Mensaje
var auth

func _ready():
    auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
    add_child(auth)
    boton_eliminar.disabled = true
    label_error.text = ""
    input_usuario.text = ""
    input_usuario.connect("text_changed", Callable(self, "_on_input_text_changed"))
    boton_eliminar.connect("pressed", Callable(self, "_on_eliminar_pressed"))


# Habilitar el botón solo si el nombre coincide exactamente
func _on_input_text_changed(new_text):
    if new_text.strip_edges() == Globals.user.get("nombre", ""):
        boton_eliminar.disabled = false
        label_error.text = ""
    else:
        boton_eliminar.disabled = true

# Función para eliminar la cuenta

   

func _on_salir_pressed() -> void:
     queue_free()


func _on_btn_eliminar_pressed() -> void:
    var uid = Globals.user.get("uid", "")
    if uid == "":
        label_error.text = "⚠ No se pudo obtener el UID del usuario."
        return

    # 1️⃣ Eliminar datos del usuario en Realtime Database
    var ruta = "usuarios/%s" % uid
    var res_db = await auth.update_user_data(uid, {})
# Opcional: puedes hacer un DELETE si tu auth lo permite
    # O si tu auth tiene método delete_document(), úsalo en vez de update_user_data

    # 2️⃣ Eliminar usuario de Firebase Authentication
    # Necesitarás el idToken del usuario actual
    var id_token = Globals.user.get("idToken", "")
    if id_token == "":
        label_error.text = "⚠ No se pudo obtener el token de usuario."
        return

    await auth.delete_user(id_token)

    # 3️⃣ Limpiar Globals y volver al login
    Globals.user.clear()
    get_tree().change_scene_to_file("res://escenas/usuario/Login/login.tscn")


func _delete_user_data(uid: String, id_token: String) -> Dictionary:
    var url = "https://galileo-af640-default-rtdb.firebaseio.com/usuarios/%s.json?auth=%s" % [uid, id_token]
    var http := HTTPRequest.new()
    add_child(http)

    var err = http.request(url, [], HTTPClient.METHOD_DELETE)
    if err != OK:
        http.queue_free()
        return {"error": "No se pudo enviar la solicitud DELETE. Código %s" % err}

    var response = await http.request_completed
    var status = response[0]
    var code = response[1]
    http.queue_free()

    if status != HTTPRequest.RESULT_SUCCESS:
        return {"error": "Error HTTP al borrar datos, código %s" % code}

    return {"ok": true}
