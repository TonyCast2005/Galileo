extends Control

@onready var titulo = $titulo
@onready var txt_verdadero = $txtverdadero
@onready var txt_falso = $txtfalso
@onready var chk_verdadero = $verdadero
@onready var chk_falso = $falso
@onready var pregunta = $Enunciado
@onready var retro = $Mensaje

var firebase
var editando_id = null

func _ready():
	firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(firebase)

	var data = Globals.temp_preview_data
	if data.has("enunciado"):
		pregunta.text = data["enunciado"]


func get_form_data(estado:String) -> Dictionary:
	var respuesta = ""
	if chk_verdadero.button_pressed:
		respuesta = "Verdadero"
	elif chk_falso.button_pressed:
		respuesta = "Falso"

	return {
		"tipo": "verdadero_falso",
		"enunciado": pregunta.text,
		"respuesta_correcta": respuesta
	}


func _on_borrador_pressed():
	Globals.temp_preview_data = get_form_data("borrador")
	pregunta.text = ""
	txt_verdadero.text = ""
	txt_falso.text = ""
	chk_verdadero.button_pressed = false
	chk_falso.button_pressed = false


func _on_eliminar_pressed():
	if editando_id == null:
		_clear_fields()
		return

	var url = "%s/preguntas/%s.json" % [firebase.DB_URL, editando_id]

	var http := HTTPRequest.new()
	add_child(http)
	await http.request(url, [], HTTPClient.METHOD_DELETE)
	http.queue_free()

	editando_id = null
	_clear_fields()
	print("Pregunta eliminada")


func _clear_fields():
	pregunta.text = ""
	txt_verdadero.text = ""
	txt_falso.text = ""
	chk_verdadero.button_pressed = false
	chk_falso.button_pressed = false


func _on_previsualizar_pressed():
	Globals.temp_preview_data = get_form_data("preview")
	get_tree().change_scene_to_file("res://escenas/Administrador/preview_verdadero_falso.tscn")


func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")


func _on_guardar_pressed():

	# Obtener respuesta
	var respuesta = ""
	if chk_verdadero.button_pressed:
		respuesta = "Verdadero"
	elif chk_falso.button_pressed:
		respuesta = "Falso"

	# Validar datos
	if pregunta.text.is_empty() or respuesta == "":
		retro.text = "Por favor completa la pregunta y selecciona una respuesta."
		retro.modulate = Color(1,0,0)
		limpiar_mensaje()
		return

	# Construir datos
	var data = {
		"pregunta": pregunta.text,
		"respuesta_correcta": respuesta
	}

	var url = "%s/preguntas_VF.json" % firebase.DB_URL

	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(data)

	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		retro.text = "Error al conectar con el servidor."
		retro.modulate = Color(1,0,0)
		limpiar_mensaje()
		return

	var response = await http.request_completed
	var body = response[3]
	var result = JSON.parse_string(body.get_string_from_utf8())

	http.queue_free()

	# Firebase devuelve un nombre si se guardó correctamente
	if result == null or not result.has("name"):
		retro.text = "Error al guardar la pregunta."
		retro.modulate = Color(1,0,0)
		limpiar_mensaje()
		return

	# Si sí se guardó
	retro.text = "Guardado correctamente."
	limpiar_mensaje()

	# Vaciar campos
	_clear_fields()

func limpiar_mensaje():
	await get_tree().create_timer(4).timeout
	retro.text = ""
