extends Control

# 🌟 1. Variable clave para el mapeo de métricas 🌟
const EXERCISE_TYPE = "OM1" 

@onready var panel_retro = $PanelRetroalimentacion
@onready var label_retro = $PanelRetroalimentacion/LabelRetroalimentacion
@onready var image_retro = $PanelRetroalimentacion/Galileo
@onready var color_rect = $PanelRetroalimentacion/ColorRect
@onready var boton_retro = $PanelRetroalimentacion/BotonSiguiente
@onready var contenedor_preguntas = $ContenedorPreguntas
@onready var progreso = $Progreso
@onready var http = $HTTPRequest  


var pistas_actuales: Array = []
var indice_pista = 0

var preguntas: Array = []
var indice_actual = 0
var contador = 1

var velocidad = 0.04
var frame_hablando = [ preload("res://assets/sprites/ui/Galileo/Feli.png") ]
var frame_idle = preload("res://assets/sprites/ui/Galileo/Galileo Base.png")

var instancia_actual = null
var panel_activo = false

# ===============================
# SISTEMA DE ERRORES
# ===============================
var errores: int = 0
var errores_maximos: int = 2

func fallar_demasiado() -> void:
	Globals.repetir_bloque = true
	get_tree().change_scene_to_file("res://escenas/Tipos_preguntas/RepiteLeccion.tscn")
	
func _ready():
	panel_retro.visible = false
	boton_retro.pressed.connect(_on_boton_retro_pressed)

	http.request_completed.connect(_on_request_completed)
	# Pide las preguntas a Firebase
	http.request("https://galileo-af640-default-rtdb.firebaseio.com/preguntas_opc.json")
		

# ============================================
# RECIBIR PREGUNTAS DESDE FIREBASE
# ============================================
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())

		if typeof(data) == TYPE_ARRAY:
			preguntas = data
		elif typeof(data) == TYPE_DICTIONARY:
			# Si Firebase devuelve un diccionario (que es lo común con las claves automáticas)
			preguntas = data.values()
		else:
			preguntas = []

		if preguntas.size() > 0:
			preguntas = preguntas.slice(0, 10) # Limitar a 10 preguntas
			cargar_pregunta(indice_actual)
		else:
			panel_retro.show()
			label_retro.text = "⚠️ No hay preguntas disponibles"
	else:
		panel_retro.show()
		label_retro.text = "❌ Error al cargar preguntas (Código: " + str(response_code) + ")"


# ============================================
# CARGAR PREGUNTA
# ============================================
func cargar_pregunta(indice: int):
	if instancia_actual:
		instancia_actual.queue_free()

	var escena = preload("res://escenas/Tipos_preguntas/OpcionMultiple/OpcionMultiple.tscn").instantiate()
	contenedor_preguntas.add_child(escena)
	instancia_actual = escena

	var pregunta = preguntas[indice]

	if instancia_actual.has_method("set_pregunta"):
		instancia_actual.set_pregunta(pregunta)

	# Conectar la señal si no está ya conectada
	if instancia_actual.has_signal("respondida") and not instancia_actual.is_connected("respondida", _on_pregunta_respondida):
		instancia_actual.respondida.connect(_on_pregunta_respondida)
		pistas_actuales = []
		indice_pista = 0

	if pregunta.has("pistas"):
		pistas_actuales = pregunta["pistas"]



# ============================================
# RESPUESTA DEL USUARIO (Lógica de Métrica y Error)
# ============================================
func _on_pregunta_respondida(texto: String, color: Color, correcta: bool):
	
	# 🌟 PASO CLAVE 1: ACTUALIZAR MÉTRICAS GLOBALES (ADAPTATIVAS) 🌟
	# ESTA LÍNEA ES LA CLAVE PARA LAS MÉTRICAS
	MetricsManager.update_methodology_score(EXERCISE_TYPE, correcta)
	
	if correcta:
		mostrar_retroalimentacion(" " + texto, color)
	else:
		var correcta_real = preguntas[indice_actual].get("respuesta_correcta", "")
		mostrar_retroalimentacion(" Incorrecto. La respuesta era: " + correcta_real, Color.RED)
		
		# 🔴 FIX: SOLO INCREMENTAR ERRORES SI LA RESPUESTA ES INCORRECTA
		errores += 1
		
	# 🔴 VERIFICACIÓN DE FALLO MÁXIMO
	if errores >= errores_maximos:
		fallar_demasiado()
		return  
		
	boton_retro.visible = true
	boton_retro.disabled = false


# ============================================
# BOTÓN SIGUIENTE
# ============================================
func _on_boton_retro_pressed():
	cerrar_panel()
	indice_actual += 1
	contador += 1
	progreso.text = "PREGUNTA " + str(contador)

	if indice_actual < preguntas.size():
		cargar_pregunta(indice_actual)
		return

	# ================================
	# TERMINÓ LA LECCIÓN → REGRESAR
	# ================================
	if not Globals.repetir_bloque:
		# 🔴 CORRECCIÓN CLAVE: Usar Globals.desbloqueados1 (asumiendo tu array de progreso)
		var progreso_array = Globals.desbloqueados1 

		var next_lesson_index = Globals.bloque_actual
		
		# Desbloquear con comprobación de límites de índice
		if next_lesson_index >= 0 and next_lesson_index < progreso_array.size():
			progreso_array[next_lesson_index] = true
		else:
			# Esto debe imprimirse si el índice global está fuera de los límites del array
			print("AVISO: Índice de desbloqueo (", next_lesson_index, ") fuera de rango.")
			
		# Avanzar el índice global a la siguiente lección si es posible
		if Globals.bloque_actual < progreso_array.size() - 1:
			Globals.bloque_actual += 1
	else:
		Globals.repetir_bloque = false 

	get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")


# ============================================
# MOSTRAR RETROALIMENTACIÓN
# ============================================
func mostrar_retroalimentacion(texto: String, color: Color):
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
	var fuera_pantalla = viewport_size.y + panel_altura
	var destino = viewport_size.y - panel_altura
	panel_retro.position.y = fuera_pantalla

	var tween = create_tween()
	tween.tween_property(panel_retro, "position:y", destino, 0.4)

	await get_tree().create_timer(0.2).timeout

	var hablando = true
	var pos_original = image_retro.position

	var boca_timer = get_tree().create_timer(velocidad * 2, true)
	boca_timer.timeout.connect(func():
		if hablando:
			image_retro.texture = frame_hablando[0]
	)

	var tween_gato = create_tween().set_loops()
	tween_gato.tween_property(image_retro, "position:y", pos_original.y - 8, 0.12)
	tween_gato.tween_property(image_retro, "position:y", pos_original.y, 0.12)

	for c in texto:
		label_retro.text += c
		await get_tree().create_timer(velocidad).timeout

	hablando = false
	image_retro.texture = frame_idle
	tween_gato.kill()
	image_retro.position = pos_original

	boton_retro.visible = true
	boton_retro.disabled = false


# ============================================
# CERRAR PANEL
# ============================================
func cerrar_panel():
	var viewport_size = get_viewport_rect().size
	var panel_altura = panel_retro.size.y
	var fuera = viewport_size.y + panel_altura

	var tween = create_tween()
	tween.tween_property(panel_retro, "position:y", fuera, 0.5)
	tween.tween_callback(func():
		panel_retro.hide()
		image_retro.hide()
		panel_activo = false)


func _on_pista_pressed() -> void:
	if pistas_actuales.is_empty():
		mostrar_retroalimentacion("No hay pistas para esta pregunta.", Color.YELLOW)
		return

	if indice_pista >= pistas_actuales.size():
		indice_pista = 0  # Reinicia si se acabaron

	var pista = pistas_actuales[indice_pista]
	indice_pista += 1

	mostrar_pista(pista)

	
var contenedor_pista = null

func mostrar_pista(pista: String) -> void:
	if contenedor_pista:
		contenedor_pista.queue_free()
	contenedor_pista = preload("res://escenas/Pistas/Pistas_Contenedor.tscn").instantiate()
	add_child(contenedor_pista)
	contenedor_pista.set_pista(pista)
