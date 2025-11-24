extends Control

@onready var nivel = $nivel
@onready var tema = $tema
@onready var nombre = $nombre
@onready var preguntas = $preguntas
@onready var retro = $Mensaje

var firebase
var editando_id: String = ""
var borrador = {}

func _ready():
	firebase = load("res://escenas/Administrador/FirebaseDB.gd").new()
	add_child(firebase)

	# Cargar borrador o preview si existe
	var data = Globals.temp_preview_data

	if data.has("nivel"): nivel.text = data["nivel"]
	if data.has("tema"): tema.text = str(data["tema"])
	if data.has("nombre"): nombre.text = data["nombre"]

	if data.has("ejercicios"):
		preguntas.text = ", ".join(data["ejercicios"])

# ----------------------------- Obtener datos -----------------------------
func get_form_data() -> Dictionary:

	var ejercicios := []
	for e in preguntas.text.split(","):
		var clean = e.strip_edges()
		if clean != "":
			ejercicios.append(clean)

	return {
		"nivel": nivel.text.strip_edges(),
		"tema": int(tema.text.strip_edges()),
		"nombre": nombre.text.strip_edges(),
		"ejercicios": ejercicios
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
		retro.text = "Campos limpiados."
		limpiar_mensaje()
		return

	var url = "%s/lecciones/%s.json" % [firebase.DB_URL, editando_id]

	var http := HTTPRequest.new()
	add_child(http)

	await http.request(url, [], HTTPClient.METHOD_DELETE)
	http.queue_free()

	editando_id = ""
	_clear_fields()

	retro.text = "Lección eliminada."
	limpiar_mensaje()


# ----------------------------- Limpiar -----------------------------
func _clear_fields():
	nivel.text = ""
	tema.text = ""
	nombre.text = ""
	preguntas.text = ""

# ----------------------------- Volver -----------------------------
func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")

# ----------------------------- Guardar en Firebase -----------------------------
func _on_guardar_pressed():

	# VALIDACIONES
	if nivel.text.strip_edges() == "":
		retro.text = "Debes ingresar el nivel."
		retro.modulate = Color.RED
		limpiar_mensaje()
		return

	if tema.text.strip_edges() == "" or not tema.text.strip_edges().is_valid_int():
		retro.text = "El tema debe ser un número."
		retro.modulate = Color.RED
		limpiar_mensaje()
		return

	if nombre.text.strip_edges() == "":
		retro.text = "Debes ingresar un nombre de lección."
		retro.modulate = Color.RED
		limpiar_mensaje()
		return

	if preguntas.text.strip_edges() == "":
		retro.text = "Debes ingresar IDs de ejercicios."
		retro.modulate = Color.RED
		limpiar_mensaje()
		return

	var data = get_form_data()

	var url = "%s/lecciones.json" % firebase.DB_URL

	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	var json := JSON.stringify(data)

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

	retro.text = "Lección guardada correctamente."
	retro.modulate = Color.GREEN
	limpiar_mensaje()

	_clear_fields()

# ----------------------------- Limpiar mensaje -----------------------------
func limpiar_mensaje():
	await get_tree().create_timer(3).timeout
	retro.text = ""
