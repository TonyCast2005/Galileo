extends Control

@onready var contenedor_bloques = $Bloques
@onready var contenedor_zonas = $Zonas
@onready var lbl_enunciado = $Enunciado
@onready var btn_pista = $Pista
@onready var mensaje = $Mensaje
@onready var http: HTTPRequest = $HTTPRequest

var escena_bloque := preload("res://escenas/Tipos_preguntas/Arrastrar_y_Soltar/Bloques_Tipos/prueba_drag&drop.gd")
var escena_pista := preload("res://escenas/Pistas/Pistas_Contenedor.tscn")
var escena_zona := preload("res://escenas/Tipos_preguntas/Arrastrar_y_Soltar/Prueba_Nueva/RestZone.tscn")

const FIREBASE_URL := "https://galileo-af640-default-rtdb.firebaseio.com/preguntas_drag.json"

var preguntas: Array[Dictionary] = []
var seleccionadas: Array[Dictionary] = []
var indice: int = 0
var pistas_actuales: Array[String] = []


func _ready():
	btn_pista.pressed.connect(_mostrar_pista)
	_cargar_preguntas()


func _cargar_preguntas():
	var err: int = http.request(FIREBASE_URL)
	if err != OK:
		lbl_enunciado.text = "No se pudo conectar con Firebase."
		return

	http.request_completed.connect(_on_request_completed)


func _on_request_completed(result, code, _headers, body):
	if code != 200:
		lbl_enunciado.text = "Error al obtener preguntas."
		return

	var data := JSON.parse_string(body.get_string_from_utf8())

	if typeof(data) == TYPE_DICTIONARY:
		for key in data.keys():
			var item = data[key]
			if typeof(item) == TYPE_DICTIONARY:
				preguntas.append(item)

	if preguntas.is_empty():
		lbl_enunciado.text = "No hay preguntas disponibles."
		return

	var tmp := preguntas.duplicate()
	tmp.shuffle()
	seleccionadas = tmp.slice(0, 4)

	_mostrar_pregunta()


func _mostrar_pregunta():
	if indice >= seleccionadas.size():
		lbl_enunciado.text = "¡Completaste todas!"
		return

	var p = seleccionadas[indice]
	lbl_enunciado.text = p["enunciado"]

	pistas_actuales = p["pistas"].duplicate()
	btn_pista.visible = pistas_actuales.size() > 0

	# Limpiar
	for c in contenedor_bloques.get_children(): c.queue_free()
	for c in contenedor_zonas.get_children(): c.queue_free()

	# Crear zonas en orden correcto
	for palabra in p["respuesta_correcta"]:
		var zona = escena_zona.instantiate()
		zona.palabra_correcta = palabra
		zona.add_to_group("zone")
		contenedor_zonas.add_child(zona)

	# Crear bloques mezclados
	var mezclados := p["bloques"].duplicate()
	mezclados.shuffle()

	for palabra in mezclados:
		var bloque = escena_bloque.instantiate()
		bloque.palabra = palabra
		contenedor_bloques.add_child(bloque)


func _mostrar_pista():
	if pistas_actuales.is_empty():
		return

	var texto = pistas_actuales.pop_front()

	var v = escena_pista.instantiate()
	add_child(v)
	v.set_pista(texto)
