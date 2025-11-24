extends Control
@onready var bloque1 = $bloque1
@onready var bloque2 = $bloque2
@onready var bloque3 = $bloque3
@onready var bloque4 = $bloque4
@onready var bloque5 = $bloque5
@onready var bloque6 = $bloque6
@onready var retro = $Mensaje
 
var firebase
var editando_id = null

func _ready():
	firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(firebase)

	var data = Globals.temp_preview_data
	if data.has("bloque1"):
		bloque1.text = data["bloque1"]
	if data.has("bloque2"):
		bloque2.text = data["bloque2"]
	if data.has("bloque3"):
		bloque3.text = data["bloque3"]
	if data.has("bloque4"):
		bloque1.text = data["bloque4"]
	if data.has("bloque5"):
		bloque2.text = data["bloque5"]
	if data.has("bloque6"):
		bloque3.text = data["bloque6"]

# ----------------------- Obtener datos del formulario -----------------------
func get_form_data(estado:String) -> Dictionary:
	return {
		"tipo": "arrastrarYsoltar",
		"bloque1": bloque1.text,
		"bloque2": bloque2.text,
		"bloque3": bloque3.text,
		"bloque4": bloque4.text,
		"bloque5": bloque5.text,
		"bloque6": bloque6.text
	}

# ----------------------- Borrador temporal -----------------------
func _on_borrador_pressed():
	Globals.temp_preview_data = get_form_data("borrador")

# ----------------------- Eliminar pregunta -----------------------
func _on_eliminar_pressed():
	if editando_id == null:
		_clear_fields()
		return

	var url = "%s/arrastrar_soltar/%s.json" % [firebase.DB_URL, editando_id]
	var http := HTTPRequest.new()
	add_child(http)
	await http.request(url, [], HTTPClient.METHOD_DELETE)
	http.queue_free()

	editando_id = null
	_clear_fields()
	print("Pregunta eliminada")

# ----------------------- Limpiar campos -----------------------
func _clear_fields():
	bloque1.text = ""
	bloque2.text = ""
	bloque3.text = ""
	bloque4.text = ""
	bloque5.text = ""
	bloque6.text = ""
# ----------------------- Previsualizar -----------------------
func _on_previsualizar_pressed():
	Globals.temp_preview_data = get_form_data("preview")
	get_tree().change_scene_to_file("res://escenas/Administrador/preview_arrastrarSoltar.tscn")

# ----------------------- Volver -----------------------
func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")

# ----------------------- Guardar en Firebase -----------------------
func _on_guardar_pressed():
	# Validar campos
	if bloque1.text.is_empty() or bloque6.text.is_empty():
		retro.text = "Favor de completar los campos"
		retro.modulate = Color(1,0,0)
		limpiar_mensaje()
		return

	# Construir datos
	var data = {
		"bloque1": bloque1.text,
		"bloque2": bloque2.text,
		"bloque3": bloque3.text,
		"bloque4": bloque4.text,
		"bloque5": bloque5.text,
		"bloque6": bloque6.text
	}

	# URL Firebase semiabiertas
	var url = "%s/arrastrar_soltar.json" % firebase.DB_URL

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
