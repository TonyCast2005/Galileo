extends Control

@onready var achievements_list = $ScrollContainer/logrosVbox
@onready var http = $HTTPRequest
@onready var label_usuario = $LabelUsuario  # Label donde mostrarás el email del usuario

var LogroScene = preload("res://escenas/usuario/Perfil/Logro.tscn")
var firebase_url = "https://galileo-af640-default-rtdb.firebaseio.com/" 

var logros = {}

func _ready():
	if Globals.user:
		var uid = Globals.user["uid"]
		var email = Globals.user["email"]
		
		# Mostrar email del usuario
		label_usuario.text = email

		# URL para cargar logros del usuario
		var url_logros = "%s/logros/%s.json" % [firebase_url, uid]
		http.request(url_logros)
	else:
		push_error("No hay usuario logueado")
		label_usuario.text = "Invitado"

# Manejo de respuesta de HTTPRequest
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code != 200:
		push_error("Error al cargar Firebase: %s" % response_code)
		return

	var data = {}
	if body.size() > 0:
		var parse_result = JSON.parse_string(body.get_string_from_utf8())
		if parse_result.error != OK:
			push_error("Error al parsear JSON: %s" % parse_result.error_string)
			return
		data = parse_result.result

	logros = data if data else {}
	mostrar_logros()

# Mostrar logros en la UI
func mostrar_logros():
	for child in achievements_list.get_children():
		child.queue_free()

	for id in logros.keys():
		var data = logros[id]
		var icon = load(data.get("icono", "res://iconos/default.png"))  # Icono por defecto si no existe
		add_achievement(icon, data.get("nombre", "Sin nombre"), data.get("descripcion", ""), true)

func add_achievement(icon: Texture, title: String, description: String, unlocked: bool):
	var logro = LogroScene.instantiate()
	achievements_list.add_child(logro)
	logro.call_deferred("set_data", icon, title, description, unlocked)

# Botón para editar perfil
func _on_editarperfil_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
