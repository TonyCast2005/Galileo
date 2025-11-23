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
var editando_id = null

func _ready():
	firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(firebase)

	var data = Globals.temp_preview_data
	if data.has("pregunta"):
		pregunta.text = data["pregunta"]
	if data.has("respuesta_modelo"):
		respuesta.text = data["respuesta_modelo"]
	if data.has("palabra1"):
		palabra1.text = data["palabra1"]
	if data.has("palabra2"):
		palabra2.text = data["palabra2"]
	if data.has("palabra3"):
		palabra3.text = data["palabra3"]
	if data.has("sinonimo1"):
		sinonimo1.text = data["sinonimo1"]
	if data.has("sinonimo2"):
		sinonimo2.text = data["sinonimo2"]
	if data.has("sinonimo3"):
		sinonimo3.text = data["sinonimo3"]

# ----------------------- Obtener datos del formulario -----------------------
func get_form_data(estado:String) -> Dictionary:
	return {
		"tipo": "semiabierta",
		"pregunta": pregunta.text,
		"palabra1": palabra1.text,
		"palabra2": palabra2.text,
		"palabra3": palabra3.text,
		"sinonimo1": sinonimo1.text,
		"sinonimo2": sinonimo2.text,
		"sinonimo3": sinonimo3.text,
		"respuesta_modelo": respuesta.text
	}

# ----------------------- Borrador temporal -----------------------
func _on_borrador_pressed():
	Globals.temp_preview_data = get_form_data("borrador")

# ----------------------- Eliminar pregunta -----------------------
func _on_eliminar_pressed():
	if editando_id == null:
		_clear_fields()
		return

	var url = "%s/preguntas_abiertas/%s.json" % [firebase.DB_URL, editando_id]
	var http := HTTPRequest.new()
	add_child(http)
	await http.request(url, [], HTTPClient.METHOD_DELETE)
	http.queue_free()

	editando_id = null
	_clear_fields()
	print("Pregunta eliminada")
		
# ----------------------- Limpiar campos -----------------------
func _clear_fields():
	pregunta.text = ""
	palabra1.text = ""
	palabra2.text = ""
	palabra3.text = ""
	sinonimo1.text = ""
	sinonimo2.text = ""
	sinonimo3.text = ""
	respuesta.text = ""

# ----------------------- Previsualizar -----------------------
func _on_previsualizar_pressed():
	Globals.temp_preview_data = get_form_data("preview")
	get_tree().change_scene_to_file("res://escenas/Administrador/preview_semiAbiertas.tscn")

# ----------------------- Volver -----------------------
func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")

# ----------------------- Guardar en Firebase -----------------------
func _on_guardar_pressed():
	# Validar campos
	if pregunta.text.is_empty() or respuesta.text.is_empty():
		retro.text = "Por favor completa la pregunta y la respuesta correcta."
		retro.modulate = Color(1,0,0)
		limpiar_mensaje()
		return

	# Construir datos
	var data = {
		"tipo": "semiabierta",
		"pregunta": pregunta.text,
		"palabra1": palabra1.text,
		"palabra2": palabra2.text,
		"palabra3": palabra3.text,
		"sinonimo1": sinonimo1.text,
		"sinonimo2": sinonimo2.text,
		"sinonimo3": sinonimo3.text,
		"respuesta_modelo": respuesta.text
	}

	# URL Firebase semiabiertas
	var url = "%s/preguntas_abiertas.json" % firebase.DB_URL

	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	var json = JSON.stringify(data)

	# POST simple con json como String
	var err = http.request(url, headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		retro.text = "Error al conectar con el servidor."
		retro.modulate = Color(1,0,0)
		limpiar_mensaje()
		return

	# Esperar respuesta
	var response = await http.request_completed
	var body = response[3]  # PackedByteArray
	var result = JSON.parse_string(body.get_string_from_utf8())

	http.queue_free()

	# Firebase devuelve un "name" si se guardó correctamente
	if result == null or not result.has("name"):
		retro.text = "Error al guardar la pregunta."
		retro.modulate = Color(1,0,0)
		limpiar_mensaje()
		return

	# Guardado exitoso
	retro.text = "Guardado correctamente."
	retro.modulate = Color(0,1,0)
	limpiar_mensaje()

	# Vaciar campos
	_clear_fields()

# ----------------------- Limpiar mensaje -----------------------
func limpiar_mensaje():
	await get_tree().create_timer(4).timeout
	retro.text = ""
