extends Node

const API_KEY = "AIzaSyBfDUbVummAFJFmuZN906DC09-hhhQcRB0"
const BASE_URL = "https://identitytoolkit.googleapis.com/v1/accounts"
const DB_URL = "https://galileo-af640-default-rtdb.firebaseio.com"

# 🔹 Registrar usuario
func register_user(email: String, password: String, nombre: String) -> Dictionary:
	var url = "%s:signUp?key=%s" % [BASE_URL, API_KEY]
	var data = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}

	var res = await _send_request(url, data)

	# Manejo de errores Firebase
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

	# Guardar datos extra en Realtime Database
	var uid = res.get("localId", "")
	if uid != "":
		var user_data = {"email": email, "nombre": nombre}
		await _save_user_data(uid, user_data)

	return res

# 🔹 Iniciar sesión
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


# 🔹 Guardar datos del usuario en Realtime Database
func _save_user_data(uid: String, user_data: Dictionary) -> void:
	var url = "%s/usuarios/%s.json" % [DB_URL, uid]
	var http := HTTPRequest.new()
	add_child(http)
	await http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_PUT, JSON.stringify(user_data))
	http.queue_free()


# 🔹 Obtener datos del usuario
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


func _patch_request(url: String, data: Dictionary) -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(data)

	var err = http.request(url, headers, HTTPClient.METHOD_PATCH, json)
	if err != OK:
		return {"error": {"message": "Error al enviar PATCH: %s" % err}}

	var response = await http.request_completed
	var status = response[0]
	var code = response[1]
	var body = response[3]

	http.queue_free()

	if status != HTTPRequest.RESULT_SUCCESS:
		return {"error": {"message": "Error en PATCH, código HTTP %s" % code}}

	var result = JSON.parse_string(body.get_string_from_utf8())
	return result

func update_user_data(uid: String, data: Dictionary) -> Dictionary:
	var url = "%s/usuarios/%s.json" % [DB_URL, uid]
	return await _patch_request(url, data)

# 🔹 Enviar POST a Firebase
func _send_request(url: String, data: Dictionary) -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)
	var json := JSON.stringify(data)
	var headers := ["Content-Type: application/json"]

	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		return {"error": {"message": "Error al enviar la solicitud: %s" % err}}

	var response = await http.request_completed
	var status = response[0]
	var response_code = response[1]
	var body = response[3]
	http.queue_free()

	if status != HTTPRequest.RESULT_SUCCESS:
		return {"error": {"message": "Solicitud fallida, código HTTP %s" % response_code}}

	var response_text = body.get_string_from_utf8()
	if response_text.is_empty():
		return {"error": {"message": "Firebase devolvió una respuesta vacía"}}

	var result = JSON.parse_string(response_text)
	if result == null:
		return {"error": {"message": "No se pudo interpretar la respuesta del servidor"}}

	return result
	
	
