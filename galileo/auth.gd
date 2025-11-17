extends Node

# Claves de Firebase
const API_KEY = "AIzaSyBfDUbVummAFJFmuZN906DC09-hhhQcRB0"
const BASE_URL = "https://identitytoolkit.googleapis.com/v1/accounts"
const DB_URL = "https://galileo-af640-default-rtdb.firebaseio.com/usuarios"

# -------------------------------------------------
#  Registro
# -------------------------------------------------
func register_user(email: String, password: String) -> Dictionary:
	var url = "%s:signUp?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	return await _send_request(url, data)

# -------------------------------------------------
#  Login
# -------------------------------------------------
func login_user(email: String, password: String) -> Dictionary:
	var url = "%s:signInWithPassword?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	return await _send_request(url, data)

# -------------------------------------------------
#  Guardar datos del usuario (nombre, foto, etc.)
# -------------------------------------------------
func save_user_data(uid: String, data: Dictionary) -> Dictionary:
	var db_url = "%s/%s.json" % [DB_URL, uid]
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

# -------------------------------------------------
#  Obtener datos del usuario
# -------------------------------------------------
func get_user_data(uid: String) -> Dictionary:
	var db_url = "%s/%s.json" % [DB_URL, uid]
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

# -------------------------------------------------
#  Cambiar contraseña
# -------------------------------------------------
func change_password(id_token: String, new_password: String) -> Dictionary:
	var url = "%s:update?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"idToken": id_token,
		"password": new_password,
		"returnSecureToken": false
	}
	return await _send_request(url, data)

# -------------------------------------------------
#  Eliminar usuario (de autenticación)
# -------------------------------------------------
func delete_user(id_token: String) -> Dictionary:
	var url = "%s:delete?key=%s" % [BASE_URL, API_KEY]
	var data = {"idToken": id_token}
	return await _send_request(url, data)

# -------------------------------------------------
#  Eliminar datos del usuario en la DB
# -------------------------------------------------
func delete_user_data(uid: String) -> Dictionary:
	var db_url = "%s/%s.json" % [DB_URL, uid]
	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(db_url, [], HTTPClient.METHOD_DELETE)
	if err != OK:
		return {"error": "Error al eliminar datos: %s" % err}

	var response = await http.request_completed
	var result = {"status": response[1]}

	http.queue_free()
	return result

# -------------------------------------------------
#  Función auxiliar para enviar peticiones HTTP
# -------------------------------------------------
func _send_request(url: String, data: Dictionary) -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)

	var json_data := JSON.stringify(data)
	var headers := ["Content-Type: application/json"]

	var err = http.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if err != OK:
		return {"error": "Error al enviar la solicitud: %s" % err}

	var response = await http.request_completed
	var status = response[1]
	var body = response[3]
	var response_text = body.get_string_from_utf8()

	var result = {}
	if response_text != "":
		result = JSON.parse_string(response_text)

	http.queue_free()

	if status != 200:
		return {"error": "Solicitud fallida", "status": status, "respuesta": result}

	return result
