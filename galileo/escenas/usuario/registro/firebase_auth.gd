extends Node

const API_KEY = "AIzaSyBfDUbVummAFJFmuZN906DC09-hhhQcRB0"
const BASE_URL = "https://identitytoolkit.googleapis.com/v1/accounts"

# ------------------------------
# Registro
# ------------------------------
func register_user(email: String, password: String) -> Dictionary:
	var url = "%s:signUp?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	return await _send_request(url, data)

# ------------------------------
# Login
# ------------------------------
func login_user(email: String, password: String) -> Dictionary:
	var url = "%s:signInWithPassword?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	return await _send_request(url, data)

# ------------------------------
# Recuperar cuenta
# ------------------------------
func recover_account(email: String) -> Dictionary:
	var url = "%s:sendOobCode?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"requestType": "PASSWORD_RESET",
		"email": email
	}
	return await _send_request(url, data)

# ------------------------------
# Guardar datos de usuario en la DB
# ------------------------------
func save_user_data(uid: String, data: Dictionary) -> Dictionary:
	var db_url = "https://galileo-af640-default-rtdb.firebaseio.com/usuarios/%s.json" % uid
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
# Obtener datos de usuario
# ------------------------------
func get_user_data(uid: String) -> Dictionary:
	var db_url = "https://galileo-af640-default-rtdb.firebaseio.com/usuarios/%s.json" % uid
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
# Enviar solicitud HTTP
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
