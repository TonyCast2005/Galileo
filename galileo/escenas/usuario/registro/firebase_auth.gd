extends Node

const API_KEY = "AIzaSyBfDUbVummAFJFmuZN906DC09-hhhQcRB0"
const BASE_URL = "https://identitytoolkit.googleapis.com/v1/accounts"
const DB_URL = "https://galileo-af640-default-rtdb.firebaseio.com"

# -----------	-----------------------------------------------
# 🔹 REGISTRAR USUARIO
# ----------------------------------------------------------
func register_user(email: String, password: String, nombre: String) -> Dictionary:
    var url = "%s:signUp?key=%s" % [BASE_URL, API_KEY]
    var data = {
        "email": email,
        "password": password,
        "returnSecureToken": true
    }

    var res = await _send_request(url, data)

    # Manejo de errores
    if res.has("error"):
        var message = res["error"].get("message", "")
        match message:
            "EMAIL_EXISTS":
                res["error"] = "El correo ya está registrado. Intenta iniciar sesión."
            "INVALID_EMAIL":
                res["error"] = "El correo no tiene un formato válido."
            "WEAK_PASSWORD : Password should be at least 6 characters":
                res["error"] = "La contraseña debe tener al menos 6 caracteres."
            _:
                res["error"] = "Error desconocido: %s" % message
        return res

    # Si Firebase devolvió UID, creamos el perfil completo
    var uid = res.get("localId", "")

    if uid != "":
        var data_inicial = _crear_data_inicial(email, nombre, password)
        await _save_user_data(uid, data_inicial)

    return res


# ----------------------------------------------------------
# 🔹 INICIAR SESIÓN
# ----------------------------------------------------------
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


# ----------------------------------------------------------
# 🔹 CREAR DATA INICIAL DE USUARIO (PERFIL COMPLETO)
# ----------------------------------------------------------
func _crear_data_inicial(email: String, nombre: String, password: String) -> Dictionary:
    return {
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


# ----------------------------------------------------------
# 🔹 GUARDAR DATA INICIAL
# ----------------------------------------------------------
func _save_user_data(uid: String, user_data: Dictionary) -> Dictionary:
    var url = "%s/usuarios/%s.json" % [DB_URL, uid]
    var http := HTTPRequest.new()
    add_child(http)

    var err = http.request(
        url,
        ["Content-Type: application/json"],
        HTTPClient.METHOD_PUT,
        JSON.stringify(user_data)
    )

    if err != OK:
        http.queue_free()
        return {"error": "No se pudo enviar la solicitud PUT. Código %s" % err}

    var response = await http.request_completed
    var status = response[0]
    var code = response[1]
    var body = response[3]

    http.queue_free()

    if status != HTTPRequest.RESULT_SUCCESS:
        return {"error": "Error HTTP al guardar: %s" % code}

    var json_result = JSON.parse_string(body.get_string_from_utf8())
    if json_result == null:
        return {"error": "Firebase regresó JSON inválido"}
    return json_result

# ----------------------------------------------------------
# 🔹 OBTENER DATA DEL USUARIO
# ----------------------------------------------------------
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

    return JSON.parse_string(body.get_string_from_utf8())


# ----------------------------------------------------------
# 🔹 PATCH (actualizar parte del perfil)
# ----------------------------------------------------------
func update_user_data(uid: String, data: Dictionary) -> Dictionary:
    var url = "%s/usuarios/%s.json" % [DB_URL, uid]
    return await _patch_request(url, data)


func _patch_request(url: String, data: Dictionary) -> Dictionary:
    var http := HTTPRequest.new()
    add_child(http)

    var headers = ["Content-Type: application/json"]
    var json = JSON.stringify(data)

    var err = http.request(url, headers, HTTPClient.METHOD_PATCH, json)
    if err != OK:
        return {"error": {"message": "Error PATCH: %s" % err}}

    var response = await http.request_completed
    var status = response[0]
    var code = response[1]
    var body = response[3]

    http.queue_free()

    if status != HTTPRequest.RESULT_SUCCESS:
        return {"error": {"message": "Error en PATCH, código %s" % code}}

    return JSON.parse_string(body.get_string_from_utf8())


# ----------------------------------------------------------
# 🔹 POST GENERAL
# ----------------------------------------------------------
func _send_request(url: String, data: Dictionary) -> Dictionary:
    var http := HTTPRequest.new()
    add_child(http)

    var json := JSON.stringify(data)
    var headers := ["Content-Type: application/json"]

    var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
    if err != OK:
        return {"error": {"message": "Error solicitud POST: %s" % err}}

    var response = await http.request_completed
    var status = response[0]
    var response_code = response[1]
    var body = response[3]

    http.queue_free()

    if status != HTTPRequest.RESULT_SUCCESS:
        return {"error": {"message": "Solicitud fallida. HTTP %s" % response_code}}

    var response_text = body.get_string_from_utf8()
    if response_text.is_empty():
        return {"error": {"message": "Firebase devolvió una respuesta vacía"}}

    var result = JSON.parse_string(response_text)
    if result == null:
        return {"error": {"message": "JSON inválido desde Firebase"}}

    return result
    
    # ----------------------------------------------------------
# 🔹 ELIMINAR USUARIO
# ----------------------------------------------------------
func delete_user(idToken: String) -> Dictionary:
    if idToken == "":
        return {"error": {"message": "Token vacío"}}

    var url = "%s:delete?key=%s" % [BASE_URL, API_KEY]
    var data = {"idToken": idToken}

    return await _send_request(url, data)
