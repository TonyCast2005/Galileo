extends Control

@onready var texto_pregunta1: Label = $TextoPregunta1
@onready var texto_pregunta2: Label = $TextoPregunta2
@onready var entrada_respuesta = $respuesta
@onready var boton_validar: Button = $validar
@onready var boton_pista: Button = $Pista
@onready var nombre_leccion: Label = $NombreLección
@onready var mensaje: Label = $Mensaje
@onready var http: HTTPRequest = $HTTPRequest

var escena_pista: PackedScene = preload("res://escenas/Pistas/Pistas_Contenedor.tscn")

const FIREBASE_URL: String = "https://galileo-af640-default-rtdb.firebaseio.com/preguntas_semiabiertas.json"

var preguntas: Array[Dictionary] = []
var preguntas_seleccionadas: Array[Dictionary] = []
var indice_actual: int = 0
var pistas_actuales: Array[String] = []


# ======================================================
# READY
# ======================================================
func _ready() -> void:
	boton_validar.pressed.connect(_on_validar_pressed)
	boton_pista.pressed.connect(_mostrar_pista)

	cargar_preguntas()

# ======================================================
# Cargar preguntas desde Firebase
# ======================================================
func cargar_preguntas() -> void:
	var err: int = http.request(FIREBASE_URL)

	if err != OK:
		push_error("Error al conectar con Firebase")
		texto_pregunta1.text = "No se pudo conectar con Firebase."
		return

	http.request_completed.connect(_on_request_completed)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:

	if response_code != 200:
		texto_pregunta1.text = "Error al obtener datos."
		return

	var data: Variant = JSON.parse_string(body.get_string_from_utf8())

	if typeof(data) == TYPE_ARRAY:
		for d in data:
			if typeof(d) == TYPE_DICTIONARY:
				preguntas.append(d)

	elif typeof(data) == TYPE_DICTIONARY:
		for key in data.keys():
			var item: Variant = data[key]
			if typeof(item) == TYPE_DICTIONARY:
				preguntas.append(item)

	if preguntas.is_empty():
		texto_pregunta1.text = "No hay preguntas disponibles."
		return

	# Elegimos 4 preguntas aleatorias:
	var copia := preguntas.duplicate()
	copia.shuffle()
	preguntas_seleccionadas = copia.slice(0, 4)

	mostrar_pregunta()


# ======================================================
# Mostrar pregunta actual
# ======================================================
func mostrar_pregunta() -> void:

	if indice_actual >= preguntas_seleccionadas.size():
		texto_pregunta1.text = "¡Has completado todas las preguntas!"
		texto_pregunta2.text = ""
		entrada_respuesta.editable = false
		boton_validar.disabled = true
		boton_pista.visible = false
		return

	var p: Dictionary = preguntas_seleccionadas[indice_actual]

	texto_pregunta1.text = p.get("pregunta", "Pregunta no disponible")
	texto_pregunta2.text = p.get("subpregunta", "")
	entrada_respuesta.text = ""
	mensaje.text = ""

	if p.has("pistas") and typeof(p["pistas"]) == TYPE_ARRAY:
		pistas_actuales = []
		for pista in p["pistas"]:
			pistas_actuales.append(String(pista))
	else:
		pistas_actuales = []

	boton_pista.visible = pistas_actuales.size() > 0


# ======================================================
# Normalizar texto
# ======================================================
func normalizar(s: String) -> String:
	var t := s.strip_edges().to_lower()

	var acentos := {
		"á":"a","é":"e","í":"i","ó":"o","ú":"u","ñ":"n"
	}

	for a in acentos.keys():
		t = t.replace(a, acentos[a])

	return t


# ======================================================
# VALIDAR
# ======================================================
func _on_validar_pressed() -> void:
	var p: Dictionary = preguntas_seleccionadas[indice_actual]

	var correcta: String = normalizar(p.get("respuesta_correcta", ""))
	var usuario: String = normalizar(entrada_respuesta.text)

	if usuario == correcta:
		mensaje.text = "✔ ¡Correcto!"
	else:
		mensaje.text = "✖ Incorrecto.\nCorrecta: " + correcta

	await get_tree().create_timer(1.3).timeout

	mensaje.text = ""
	indice_actual += 1
	mostrar_pregunta()

# ======================================================
# MOSTRAR PISTA (gatito)
# ======================================================
func _mostrar_pista() -> void:
	if pistas_actuales.is_empty():
		return

	var texto: String = pistas_actuales.pop_front()

	var ventana := escena_pista.instantiate()
	add_child(ventana)
	ventana.set_pista(texto)
