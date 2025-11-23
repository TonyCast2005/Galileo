extends Control

@onready var pregunta = $pregunta
@onready var respuesta = $respuesta
@onready var palabra1 = $palabra1
@onready var palabra2 = $palabra2
@onready var palabra3 = $palabra3
@onready var sinonimo1 = $sinonimos1
@onready var sinonimo2 = $sinonimos2
@onready var sinonimo3 = $sinonimos3
@onready var retro = $Mensaje

var firebase
var editando_id: String = ""
var borrador = {}

func _ready():
	print("pregunta:", pregunta)
	print("respuesta:", respuesta)
	print("palabra1:", palabra1)
	print("palabra2:", palabra2)
	print("palabra3:", palabra3)
	print("sinonimo1:", sinonimo1)
	print("sinonimo2:", sinonimo2)
	print("sinonimo3:", sinonimo3)

	firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(firebase)

	# Si venimos del preview o de un borrador:
	var data = Globals.temp_preview_data

	if data.has("pregunta"): pregunta.text = data["pregunta"]
	if data.has("respuesta_modelo"): respuesta.text = data["respuesta_modelo"]

	if data.has("palabra1"): palabra1.text = data["palabra1"]
	if data.has("palabra2"): palabra2.text = data["palabra2"]
	if data.has("palabra3"): palabra3.text = data["palabra3"]

	if data.has("sinonimo1"): sinonimo1.text = data["sinonimo1"]
	if data.has("sinonimo2"): sinonimo2.text = data["sinonimo2"]
	if data.has("sinonimo3"): sinonimo3.text = data["sinonimo3"]


# ----------------------------- Obtener datos -----------------------------
func get_form_data() -> Dictionary:
	return {
		"tipo": "abierta",
		"pregunta": pregunta.text,
		"respuesta_modelo": respuesta.text,

		"palabra1": palabra1.text,
		"palabra2": palabra2.text,
		"palabra3": palabra3.text,

		"sinonimo1": sinonimo1.text,
		"sinonimo2": sinonimo2.text,
		"sinonimo3": sinonimo3.text
	}


# ----------------------------- Borrador -----------------------------
func _on_borrador_pressed():
	Globals.temp_preview_data = get_form_data()
	retro.text = "Borrador guardado."
	retro.modulate = Color(0.4, 0.6, 1)
	limpiar_mensaje()


# ----------------------------- Eliminar -----------------------------
func _on_eliminar_pressed():
	if editando_id == "":
		_clear_fields()
		return

	var url = "%s/preguntas_abiertas/%s.json" % [firebase.DB_URL, editando_id]

	var http := HTTPRequest.new()
	add_child(http)

	await http.request(url, [], HTTPClient.METHOD_DELETE)
	http.queue_free()

	editando_id = ""
	_clear_fields()

	retro.text = "Pregunta eliminada."
	limpiar_mensaje()


# ----------------------------- Limpiar -----------------------------
func _clear_fields():
	pregunta.text = ""
	respuesta.text = ""
	palabra1.text = ""
	palabra2.text = ""
	palabra3.text = ""
	sinonimo1.text = ""
	sinonimo2.text = ""
	sinonimo3.text = ""


# ----------------------------- Previsualizar -----------------------------
func _on_previsualizar_pressed():
	Globals.temp_preview_data = get_form_data()
	get_tree().change_scene_to_file("res://escenas/Administrador/preview_abiertas.tscn")


# ----------------------------- Volver -----------------------------
func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")


# ----------------------------- Guardar en Firebase -----------------------------
func _on_guardar_pressed():

	if pregunta.text.is_empty() or respuesta.text.is_empty():
		retro.text = "Debes llenar la pregunta y respuesta correcta."
		retro.modulate = Color.RED
		limpiar_mensaje()
		return

	var data = get_form_data()

	var url = "%s/preguntas_abiertas.json" % firebase.DB_URL

	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	var json := JSON.stringify(data)

	# GODOT 4: request(url, headers, METHOD, body)
	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		retro.text = "Error al enviar datos."
		retro.modulate = Color.RED
		limpiar_mensaje()
		return

	var response = await http.request_completed
	var body: PackedByteArray = response[3]
	var result = JSON.parse_string(body.get_string_from_utf8())

	http.queue_free()

	if result == null or not result.has("name"):
		retro.text = "Error al guardar."
		retro.modulate = Color.RED
		limpiar_mensaje()
		return

	retro.text = "Guardado correctamente."
	retro.modulate = Color.GREEN
	limpiar_mensaje()

	_clear_fields()


# ----------------------------- Limpiar mensaje -----------------------------
func limpiar_mensaje():
	await get_tree().create_timer(3).timeout
	retro.text = ""
