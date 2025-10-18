extends Node

const API_KEY = "AIzaSyBfDUbVummAFJFmuZN906DC09-hhhQcRB0"
const BASE_URL = "https://identitytoolkit.googleapis.com/v1/accounts"

func register_user(email: String, password: String) -> Dictionary:
	var url = "%s:signUp?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	return await _send_request(url, data)

func login_user(email: String, password: String) -> Dictionary:
	var url = "%s:signInWithPassword?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	return await _send_request(url, data)


# --------------------------------------------------------------------
# 📧 Función: Recuperar cuenta mediante correo electrónico
# --------------------------------------------------------------------
func recover_account(email: String) -> Dictionary:
	var url = "%s:sendOobCode?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"requestType": "PASSWORD_RESET",
		"email": email
	}
	return await _send_request(url, data)


# --------------------------------------------------------------------
# ⚙️ Función interna: Enviar solicitud HTTP a Firebase (versión Godot 4)
# --------------------------------------------------------------------
func _send_request(url: String, data: Dictionary) -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)

	var json := JSON.stringify(data)
	var headers := ["Content-Type: application/json"]

	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		return {"error": "Error al enviar la solicitud: %s" % err}

	# Esperar a que Firebase responda
	var response = await http.request_completed
	var status = response[0]
	var response_code = response[1]
	var body = response[3]

	# Verificar si la solicitud fue exitosa
	if status != HTTPRequest.RESULT_SUCCESS:
		return {"error": "Solicitud fallida, código HTTP %s" % response_code}

	# Leer el cuerpo de la respuesta
	var response_text = body.get_string_from_utf8()
	if response_text.is_empty():
		return {"error": "Firebase devolvió una respuesta vacía"}

	# Mostrar respuesta (opcional para depurar)
	# print("Firebase respuesta cruda: ", response_text)

	var result = JSON.parse_string(response_text)

	http.queue_free()

	if result == null:
		return {"error": "No se pudo interpretar la respuesta del servidor"}
	
	return result
	
	
