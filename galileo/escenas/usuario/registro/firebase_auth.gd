extends Node

const API_KEY = "AIzaSyBfDUbVummAFJFmuZN906DC09-hhhQcRB0"
const BASE_URL = "https://identitytoolkit.googleapis.com/v1/accounts"
const DB_URL = "https://galileo-af640-default-rtdb.firebaseio.com"

# ------------------------------
# 🔹 Registrar usuario
# ------------------------------
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
        # Guardar datos adicionales en la DB
        var user_data = {
            "email": email,
            "nombre": nombre
        }
        await save_user_data(uid, user_data)
    
    return res

# ------------------------------
# 🔹 Iniciar sesión
# ------------------------------
func login_user(email: String, password: String) -> Dictionary:
    var url = "%s:signInWithPassword?key=%s" % [BASE_URL, API_KEY]
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
        var user_data = await get_user_data(uid)
        if typeof(user_data) == TYPE_DICTIONARY and user_data.has("nombre"):
            res["nombre"] = user_data["nombre"]
        else:
            res["nombre"] = "Usuario sin nombre"

    return res

# ------------------------------
# 🔹 Guardar datos de usuario
# ------------------------------
func save_user_data(uid: String, data: Dictionary) -> Dictionary:
    var db_url = "%s/usuarios/%s.json" % [DB_URL, uid]
    var http := HTTPRequest.new()
    add_child(http)

    var json_data = JSON.stringify(data)
    var headers = ["Content-Type: application/json"]

    var err = http.request(db_url, headers, HTTPClient.METHOD_PUT, json_data)
    if err != OK:
        return {"error": "Error al enviar solicitud: %s" % err}

    var response = await http.request_completed
    var body = response[3]
    var result = JSON.parse_string(body.get_string_from_utf8())

    http.queue_free()
    return result

# ------------------------------
# 🔹 Obtener datos de usuario
# ------------------------------
func get_user_data(uid: String) -> Dictionary:
    var db_url = "%s/usuarios/%s.json" % [DB_URL, uid]
    var http := HTTPRequest.new()
    add_child(http)

    var err = http.request(db_url)
    if err != OK:
        return {"error": "Error en la solicitud: %s" % err}

    var response = await http.request_completed
    var body = response[3]
    var result = JSON.parse_string(body.get_string_from_utf8())

    http.queue_free()
    return result

# ------------------------------
# 🔹 Cambiar contraseña
# ------------------------------
func change_password(id_token: String, new_password: String) -> Dictionary:
    var url = "%s:update?key=%s" % [BASE_URL, API_KEY]
    var data = {
        "idToken": id_token,
        "password": new_password,
        "returnSecureToken": true
    }
    return await _send_request(url, data)

# ------------------------------
# 🔹 Eliminar usuario
# ------------------------------
func delete_user(id_token: String) -> Dictionary:
    var url = "%s:delete?key=%s" % [BASE_URL, API_KEY]
    var data = {"idToken": id_token}
    return await _send_request(url, data)

func delete_user_data(uid: String) -> void:
    var db_url = "%s/usuarios/%s.json" % [DB_URL, uid]
    var http := HTTPRequest.new()
    add_child(http)
    await http.request(db_url, [], HTTPClient.METHOD_DELETE)
    http.queue_free()

# ------------------------------
# 🔹 Enviar solicitud HTTP
# ------------------------------
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

    if status != HTTPRequest.RESULT_SUCCESS:
        return {"error": "Solicitud fallida, código HTTP %s" % response_code}

    var response_text = body.get_string_from_utf8()
    if response_text.is_empty():
        return {"error": "Firebase devolvió una respuesta vacía"}

    var result = JSON.parse_string(response_text)
    http.queue_free()

    if result == null:
        return {"error": "No se pudo interpretar la respuesta del servidor"}

    return result
