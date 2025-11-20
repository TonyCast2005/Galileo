extends Control

@onready var titulo = $titulo
@onready var txt_verdadero = $txtverdadero
@onready var txt_falso = $txtfalso
@onready var chk_verdadero = $verdadero
@onready var chk_falso = $falso

var firebase      # referencia al script firebase_auth
var editando_id = null  # si es borrador cargado

func _ready():
	firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(firebase)
	var data = Globals.temp_preview_data
	$Enunciado.text = data["enunciado"]
	
func get_form_data(estado:String) -> Dictionary:
	var respuesta = ""
	if chk_verdadero.button_pressed:
		respuesta = "verdadero"
	elif chk_falso.button_pressed:
		respuesta = "falso"

	return {
		"tipo": "verdadero_falso",
		"enunciado": titulo.text,
		"respuesta_correcta": respuesta,
		"retro_verdadero": txt_verdadero.text,
		"retro_falso": txt_falso.text,
		"estado": estado
	}

func _on_borrador_pressed():
	var data = get_form_data("borrador")

	var id = editando_id if editando_id != null else str(Time.get_ticks_msec())

	await firebase.update_user_data("preguntas/%s" % id, data)

	editando_id = id

	print("Guardado como borrador")

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
	titulo.text = ""
	txt_verdadero.text = ""
	txt_falso.text = ""
	chk_verdadero.button_pressed = false
	chk_falso.button_pressed = false

func _on_previsualizar_pressed():
	Globals.temp_preview_data = get_form_data("preview")
	get_tree().change_scene_to_file("res://escenas/preview/preview_verdadero_falso.tscn")
	
func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")
