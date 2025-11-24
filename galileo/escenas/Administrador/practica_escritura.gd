extends Control

@onready var instruccion = $instruccion
@onready var respuesta = $respuesta
@onready var codigo = $codigo
@onready var mensaje = $Mensaje

var firebase
var editando_id : String = ""
var borrador = {}

func _ready():
	firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(firebase)

	# Cargar borrador temporal si existe
	var data = Globals.temp_preview_data

	if data.has("enunciado"): instruccion.text = data["enunciado"]
	if data.has("plantilla"): codigo.text = data["plantilla"]
	if data.has("respuestas_correctas"):
		respuesta.text = ",".join(data["respuestas_correctas"])

	if data.has("campos"):
		# Aunque no exista un campo visible para "campos", lo demos por bueno
		pass


# =========================================================
# Obtener datos del formulario
# =========================================================
func get_form_data() -> Dictionary:
	var lista_respuestas = []

	# Convertir string "100,50,30" → ["100","50","30"]
	if not respuesta.text.is_empty():
		lista_respuestas = respuesta.text.split(",", false)
		for i in range(lista_respuestas.size()):
			lista_respuestas[i] = lista_respuestas[i].strip_edges()

	return {
		"enunciado": instruccion.text,
		"plantilla": codigo.text,
		"respuestas_correctas": lista_respuestas,
		"campos": lista_respuestas.size()
	}


# =========================================================
# GUARDAR EN FIREBASE
# =========================================================
func _on_guardar_pressed():

	# Validaciones
	if instruccion.text.strip_edges() == "":
		_show_error("La instrucción no puede estar vacía.")
		return

	if codigo.text.strip_edges() == "":
		_show_error("El código no puede estar vacío.")
		return

	if respuesta.text.strip_edges() == "":
		_show_error("Debes escribir al menos una respuesta esperada.")
		return

	var data = get_form_data()

	var url = "%s/practica_escritura.json" % firebase.DB_URL
	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(data)

	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		_show_error("Error al enviar datos al servidor.")
		return

	var response = await http.request_completed
	var body = response[3]
	var result = JSON.parse_string(body.get_string_from_utf8())

	http.queue_free()

	if result == null or not result.has("name"):
		_show_error("Error al guardar en Firebase.")
		return

	_show_success("Pregunta guardada correctamente.")
	_clear_fields()


# =========================================================
# BORRADOR
# =========================================================
func _on_borrador_pressed():
	Globals.temp_preview_data = get_form_data()
	_show_success("Borrador guardado.")


# =========================================================
# ELIMINAR (solo si está editando)
# =========================================================
func _on_eliminar_pressed():
	if editando_id == "":
		_clear_fields()
		return

	var url = "%s/practica_escritura/%s.json" % [firebase.DB_URL, editando_id]

	var http := HTTPRequest.new()
	add_child(http)

	await http.request(url, [], HTTPClient.METHOD_DELETE)
	http.queue_free()

	editando_id = ""
	_clear_fields()
	_show_success("Pregunta eliminada.")


# =========================================================
# PREVISUALIZAR
# =========================================================
func _on_previsualizar_pressed():
	Globals.temp_preview_data = get_form_data()
	get_tree().change_scene_to_file("res://escenas/Administrador/preview_practicaEscritura.tscn")


# =========================================================
# VOLVER
# =========================================================
func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")


# =========================================================
# LIMPIAR CAMPOS
# =========================================================
func _clear_fields():
	instruccion.text = ""
	codigo.text = ""
	respuesta.text = ""


# =========================================================
# MENSAJES
# =========================================================
func _show_error(txt:String):
	mensaje.text = txt
	mensaje.modulate = Color(1,0,0)
	limpiar_mensaje()

func _show_success(txt:String):
	mensaje.text = txt
	mensaje.modulate = Color(0,1,0)
	limpiar_mensaje()

func limpiar_mensaje():
	await get_tree().create_timer(3).timeout
	mensaje.text = ""
