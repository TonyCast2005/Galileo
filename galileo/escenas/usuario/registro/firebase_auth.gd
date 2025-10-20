extends Node

const API_KEY = "AIzaSyBfDUbVummAFJFmuZN906DC09-hhhQcRB0"
const BASE_URL = "https://identitytoolkit.googleapis.com/v1/accounts"
const DB_URL = "https://galileo-af640-default-rtdb.firebaseio.com"

# Registrar usuario
func register_user(email: String, password: String, nombre: String) -> Dictionary:
    var url = "%s:signUp?key=%s" % [BASE_URL, API_KEY]
    var data = {
        "email": email,
        "password": password,
        "returnSecureToken": true
    }

    var res = await _send_request(url, data)
    if res.has("error"):
        return res

    var uid = res.get("localId", "")
    if uid != "":
        var user_data = {"email": email, "nombre": nombre}
        await _save_user_data(uid, user_data)

    return res

# Iniciar sesión
func login_user(email: String, password: String) -> Dictionary:
    var url = "%s:signInWithPassword?key=%s" % [BASE_URL, API_KEY]
    var data = {"email": email, "password": password, "returnSecureToken": true}

    var res = await _send_request(url, data)
    if res.has("error"):
        return res

    var uid = res.get("localId", "")
    if uid != "":
        var extra_data = await _get_user_data(uid)
        if extra_data != null:
            res["nombre"] = extra_data.get("nombre", "Usuario sin nombre")

    return res

# Guardar datos en Realtime Database
func _save_user_data(uid: String, user_data: Dictionary) -> void:
    var url = "%s/usuarios/%s.json" % [DB_URL, uid]
    var http := HTTPRequest.new()
    add_child(http)
    await http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_PUT, JSON.stringify(user_data))
    http.queue_free()

# Obtener datos del usuario
func _get_user_data(uid: String) -> Variant:
    var url = "%s/usuarios/%s.json" % [DB_URL, uid]
    var http := HTTPRequest.new()
    add_child(http)
    var err = http.request(url)
    if err != OK:
        http.queue_free()
        return null

    var response = await http.request_completed
    var status = response[0]
    var response_code = response[1]
    var body = response[3]
    http.queue_free()

    if status != HTTPRequest.RESULT_SUCCESS or response_code != 200:
        return null

    var result = JSON.parse_string(body.get_string_from_utf8())
    return result

# Función base para enviar POST a Firebase
func _send_request(url: String, data: Dictionary) -> Dictionary:
    var http := HTTPRequest.new()
    add_child(http)
    var json := JSON.stringify(data)
    var headers := ["Content-Type: application/json"]

    var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
    if err != OK:
        return {"error": "Error al enviar la solicitud: %s" % err}

    var response = await http.request_completed
    var status = response[0]
    var response_code = response[1]
    var body = response[3]
    http.queue_free()

    if status != HTTPRequest.RESULT_SUCCESS:
        return {"error": "Solicitud fallida, código HTTP %s" % response_code}

    var response_text = body.get_string_from_utf8()
    if response_text.is_empty():
        return {"error": "Firebase devolvió una respuesta vacía"}

    var result = JSON.parse_string(response_text)
    if result == null:
        return {"error": "No se pudo interpretar la respuesta del servidor"}

    return result
