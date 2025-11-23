extends Node

# 🔹 IMPORTANTE: Firebase Database URL
const DB_URL = "https://galileo-af640-default-rtdb.firebaseio.com"

# ==========================================================
# GUARDAR PREGUNTAS VERDADERO/FALSO
# ==========================================================
func save_question_VF(data: Dictionary) -> Dictionary:
	var url = "%s/preguntas_VF.json" % DB_URL

	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(data)

	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		return {"error": "No se pudo enviar solicitud POST"}

	var response = await http.request_completed
	var body = response[3]

	http.queue_free()

	var result = JSON.parse_string(body.get_string_from_utf8())
	return result

# ==========================================================
# GUARDAR PREGUNTAS OPCIÓN MÚLTIPLE
# ==========================================================


func save_question_OPC(data: Dictionary) -> Dictionary:
	var url = "%s/preguntas_opc.json" % DB_URL

	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(data)

	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		return {"error": "No se pudo enviar POST"}

	var response = await http.request_completed
	var body = response[3]

	http.queue_free()

	var result = JSON.parse_string(body.get_string_from_utf8())
	return result

# ==========================================================
# GUARDAR PREGUNTAS SEMIABIERTAS
# ==========================================================
func save_question_semiabierta(data: Dictionary) -> Dictionary:
	var url = "%s/preguntas_semiabiertas.json" % DB_URL

	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(data)

	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		return {"error": "No se pudo enviar solicitud POST"}

	var response = await http.request_completed
	var body = response[3]

	http.queue_free()

	var result = JSON.parse_string(body.get_string_from_utf8())
	return result
	
	# ==========================================================
# GUARDAR arrastrar y soltar
# ==========================================================
func save_question_arrastrarSoltar(data: Dictionary) -> Dictionary:
	var url = "%s/arrastrar_soltar.json" % DB_URL

	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(data)

	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		return {"error": "No se pudo enviar solicitud POST"}

	var response = await http.request_completed
	var body = response[3]

	http.queue_free()

	var result = JSON.parse_string(body.get_string_from_utf8())
	return result
