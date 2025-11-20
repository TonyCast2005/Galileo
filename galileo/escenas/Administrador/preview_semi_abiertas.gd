extends Control

@onready var texto_pregunta1 = $TextoPregunta1
@onready var texto_pregunta2 = $TextoPregunta2
@onready var entrada_respuesta = $respuesta
@onready var boton_validar = $validar
@onready var mensaje = $Mensaje

var data = {}  # Datos enviados desde el administrador (Globals.temp_preview_data)

func _ready():
	# Obtener los datos de previsualización
	data = Globals.temp_preview_data

	if data.is_empty():
		texto_pregunta1.text = "Sin datos para previsualizar."
		texto_pregunta2.text = ""
		boton_validar.disabled = true
		return

	# Mostrar pregunta y subpregunta
	texto_pregunta1.text = data.get("pregunta", "Sin enunciado")
	texto_pregunta2.text = data.get("subpregunta", "")

	# Limpiar campo de respuesta y mensaje
	entrada_respuesta.text = ""
	mensaje.visible = false

	# Limpiar conexiones previas y conectar botón validar
	for s in boton_validar.pressed.get_connections():
		boton_validar.pressed.disconnect(s["callable"])
	boton_validar.pressed.connect(func(): validar_respuesta(data))

# ----------------------- Validar respuesta -----------------------
func validar_respuesta(pregunta: Dictionary):
	var correcta = pregunta.get("respuesta_correcta", "").to_lower().strip_edges()
	var respuesta_usuario = entrada_respuesta.text.to_lower().strip_edges()

	if respuesta_usuario == correcta:
		mensaje.text = "¡Correcto!"
		mensaje.modulate = Color.GREEN
	else:
		mensaje.text = "Incorrecto :("
		mensaje.modulate = Color.RED

	mensaje.visible = true

# ----------------------- Volver al formulario -----------------------
func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/preguntasSemiAbiertas.tscn")
