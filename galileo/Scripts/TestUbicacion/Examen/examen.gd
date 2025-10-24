extends Control

@onready var panel_retro = $PanelRetroalimentacion
@onready var label_retro = $PanelRetroalimentacion/LabelRetroalimentacion
@onready var image_retro = $PanelRetroalimentacion/Galileo
@onready var color_rect = $PanelRetroalimentacion/ColorRect
@onready var boton_retro = $PanelRetroalimentacion/BotonSiguiente
@onready var contenedor_preguntas = $ContenedorPreguntas
@onready var progreso = $Progreso
@onready var http = $HTTPRequest  

var puntaje = 0
var correctas = 0
var nivel_actual = "novato"
var contador = 1

signal siguiente_pregunta

# ================================
# VARIABLES
# ================================
var preguntas: Array = []   # aquí van las preguntas descargadas desde Firebase
var velocidad = 0.04
var frame_hablando = [ preload("res://assets/sprites/ui/Galileo/Feli.png") ]
var frame_idle = preload("res://assets/sprites/ui/Galileo/Galileo Base.png")

var panel_activo = false
var indice_actual = 0
var instancia_actual = null
var ultima_correcta = false

# ================================
# READY
# ================================
func _ready():
	panel_retro.visible = false
	boton_retro.pressed.connect(_on_boton_retro_pressed)

	# Conectar HTTPRequest
	http.request_completed.connect(_on_request_completed)

	# Hacer la petición a Firebase
	var url = "https://galileo-af640-default-rtdb.firebaseio.com/examen_ubicacion.json"
	http.request(url)

# ================================
# HTTP RESPONSE
# ================================
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		if typeof(data) == TYPE_ARRAY:
			preguntas = data
		elif typeof(data) == TYPE_DICTIONARY:
			preguntas = data.values()
		else:
			preguntas = []

		if preguntas.size() > 0:
			# Ordenar preguntas por nivel
			preguntas.sort_custom(func(a, b):
				var orden = {"novato": 0, "competente": 1, "experimentado": 2}
				return orden.get(a["nivel"], 99) < orden.get(b["nivel"], 99)
			)

			# Tomar solo 10 (en orden)
			preguntas = preguntas.slice(0, 10)

			cargar_pregunta(indice_actual)
		else:
			label_retro.text = "⚠️ No hay preguntas disponibles"
			panel_retro.show()
	else:
		label_retro.text = "❌ Error al cargar preguntas"
		panel_retro.show()

# ================================
# CARGAR PREGUNTA
# ================================
# ================================
# CARGAR PREGUNTA
# ================================
func cargar_pregunta(indice: int):
	if instancia_actual:
		instancia_actual.queue_free()

	var escena = preload("res://escenas/Tipos_preguntas/OpcionMultiple/OpcionMultiple.tscn").instantiate()
	contenedor_preguntas.add_child(escena)
	instancia_actual = escena

	var pregunta = preguntas[indice]

	if instancia_actual.has_method("set_pregunta"):
		instancia_actual.set_pregunta(pregunta)

  
	if instancia_actual.has_signal("respondida") and not instancia_actual.is_connected("respondida", _on_pregunta_respondida):
		instancia_actual.respondida.connect(_on_pregunta_respondida)


# ================================
# MANEJAR RESPUESTA
# ================================
func _on_pregunta_respondida(texto: String, color: Color, correcta: bool):
	ultima_correcta = correcta

	if indice_actual < preguntas.size():
		var pregunta = preguntas[indice_actual]
		var nivel_preg = pregunta.get("nivel", "novato")

		# ================================
		# REGLAS DE PUNTUACIÓN
		# ================================
		match nivel_preg:
			"novato":
				if correcta:
					puntaje += 2
				else:
					puntaje -= 2
			"competente":
				if correcta:
					puntaje += 3
				# incorrecta no suma ni resta
			"experimentado":
				if correcta:
					puntaje += 5
				# incorrecta no suma ni resta

		if correcta:
			correctas += 1
			nivel_actual = nivel_preg
			mostrar_retroalimentacion("✅ " + texto, color)
		else:
			mostrar_retroalimentacion("❌ Incorrecto. La respuesta era: " + pregunta.get("respuesta_correcta", ""), Color.RED)

	boton_retro.visible = true
	boton_retro.disabled = false


# ================================
# BOTÓN DE RETROALIMENTACIÓN
# ================================
func _on_boton_retro_pressed():
	cerrar_panel()
	indice_actual += 1
	contador += 1   # ✅ suma 1 al contador
	
	progreso.text = "PREGUNTA NUMERO " + str(contador)   # ✅ cambia el texto correctamente
	
	if indice_actual < preguntas.size():
		cargar_pregunta(indice_actual)
	else:
		# Calcular nivel en base al puntaje acumulado
		var nivel_final = ""
		if puntaje <= 4:
			nivel_final = "Novato"
		elif puntaje <= 14:
			nivel_final = "Competente"
		else:
			nivel_final = "Experimentado"

		var resultado = {
			"correctas": correctas,
			"total": preguntas.size(),
			"puntaje": puntaje,
			"nivel": nivel_final
		}
		Global.set("resultado_examen", resultado)
		get_tree().change_scene_to_file("res://escenas/usuario/Mensajes/AvisoNivel.tscn")


# ================================
# FUNCIÓN DE RETROALIMENTACIÓN
# ================================
func mostrar_retroalimentacion(texto: String, color: Color) -> void:
	if panel_activo: return
	panel_activo = true

	label_retro.text = ""
	color_rect.color = color
	panel_retro.visible = true
	image_retro.visible = true
	boton_retro.visible = false
	boton_retro.disabled = true

	var viewport_size = get_viewport_rect().size
	var panel_altura = panel_retro.size.y
	var target_y = viewport_size.y - panel_altura
	var fuera_pantalla = viewport_size.y + panel_altura
	panel_retro.position.y = fuera_pantalla

	# Animación de entrada
	var tween = create_tween()
	tween.tween_property(panel_retro, "position:y", target_y, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(0.2).timeout

	# Animación del gato
	var hablando = true
	var cambio_boca = 0
	var boca_timer = get_tree().create_timer(velocidad * 2, true)
	boca_timer.timeout.connect(func():
		if hablando:
			image_retro.texture = frame_hablando[cambio_boca % frame_hablando.size()]
			cambio_boca += 1
	)

	var pos_original = image_retro.position
	var tween_gato = create_tween().set_loops()
	tween_gato.tween_property(image_retro, "position:y", pos_original.y - 8, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_gato.tween_property(image_retro, "position:y", pos_original.y, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Texto letra por letra
	for i in texto.length():
		label_retro.text += texto[i]
		await get_tree().create_timer(velocidad).timeout

	hablando = false
	image_retro.texture = frame_idle
	tween_gato.kill()
	image_retro.position = pos_original

	boton_retro.visible = true
	boton_retro.disabled = false

# ================================
# CERRAR PANEL
# ================================
func cerrar_panel():
	var viewport_size = get_viewport_rect().size
	var panel_altura = panel_retro.size.y
	var fuera_pantalla = viewport_size.y + panel_altura

	var tween_out = create_tween()
	tween_out.tween_property(panel_retro, "position:y", fuera_pantalla, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_out.tween_callback(func():
		panel_retro.hide()
		image_retro.hide()
		panel_activo = false
	)
