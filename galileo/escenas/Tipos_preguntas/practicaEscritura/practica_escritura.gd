extends Control

@onready var lbl_enunciado: Label = $Enunciado
@onready var lbl_codigo = $Codigo
@onready var cont_campos = $Campos
@onready var retro: Label = $Retro
@onready var btn_pista: Button = $Pista
@onready var http: HTTPRequest = $HTTPRequest

var EscenaPista: PackedScene = preload("res://escenas/Pistas/Pistas_Contenedor.tscn")

const FIREBASE_URL: String = "https://galileo-af640-default-rtdb.firebaseio.com/practica_escritura.json"

var preguntas: Array[Dictionary] = []
var seleccionadas: Array[Dictionary] = []
var indice_actual: int = 0
var respuestas_correctas: Array[String] = []
var campos: Array[LineEdit] = []
var pistas_actuales: Array[String] = []


# ============================================================
# READY
# ============================================================
func _ready() -> void:
	btn_pista.pressed.connect(_mostrar_pista)
	cargar_preguntas()

# ===============================
# SISTEMA DE ERRORES
# ===============================
var errores: int = 0
var errores_maximos: int = 2

func fallar_demasiado() -> void:
	Globals.desbloquear = false
	get_tree().change_scene_to_file("res://escenas/Tipos_preguntas/RepiteLeccion.tscn")
	
# ============================================================
# CARGAR PREGUNTAS
# ============================================================
func cargar_preguntas() -> void:
	var err: int = http.request(FIREBASE_URL)

	if err != OK:
		lbl_enunciado.text = "Error al conectar con Firebase"
		return

	http.request_completed.connect(_on_request_completed)


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:

	if response_code != 200:
		lbl_enunciado.text = "Error al conectar con Firebase"
		return

	var data: Variant = JSON.parse_string(body.get_string_from_utf8())

	# Convertir a array usable
	if typeof(data) == TYPE_DICTIONARY:
		for key in data.keys():
			var p: Variant = data[key]
			if typeof(p) == TYPE_DICTIONARY:
				preguntas.append(p)

	elif typeof(data) == TYPE_ARRAY:
		for p in data:
			if typeof(p) == TYPE_DICTIONARY:
				preguntas.append(p)

	if preguntas.is_empty():
		lbl_enunciado.text = "No hay preguntas disponibles."
		return

	var tmp: Array = preguntas.duplicate()
	tmp.shuffle()
	seleccionadas = tmp.slice(0, 4)

	mostrar_pregunta()


# ============================================================
# MOSTRAR PREGUNTA
# ============================================================
func mostrar_pregunta() -> void:

	if indice_actual >= seleccionadas.size():
		lbl_enunciado.text = "¡Terminaste la práctica!"
		Globals.desbloquear = true;
		get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")
		lbl_codigo.visible = false
		cont_campos.visible = false
		btn_pista.visible = false
		return

	var pregunta: Dictionary = seleccionadas[indice_actual]

	lbl_enunciado.text = pregunta.get("enunciado", "Sin enunciado")
	lbl_codigo.text = pregunta.get("plantilla", "")

	# Respuestas correctas
	respuestas_correctas = []
	for r in pregunta.get("respuestas_correctas", []):
		respuestas_correctas.append(String(r))

	# Pistas
	pistas_actuales = []
	for p in pregunta.get("pistas", []):
		pistas_actuales.append(String(p))

	btn_pista.visible = pistas_actuales.size() > 0

	# Número de campos
	var cantidad: int = pregunta.get("campos", respuestas_correctas.size())

	# Limpiar campos anteriores
	for c in cont_campos.get_children():
		c.queue_free()

	campos.clear()

	for i in range(cantidad):
		var input: LineEdit = LineEdit.new()
		input.placeholder_text = "Respuesta " + str(i + 1)
		cont_campos.add_child(input)
		campos.append(input)

	retro.text = ""
	retro.modulate = Color.WHITE


# ============================================================
# NORMALIZAR TEXTO
# ============================================================
func normalizar(s: String) -> String:
	var t: String = s.to_lower().strip_edges()

	var acentos := {
		"á":"a","é":"e","í":"i","ó":"o","ú":"u",
		"ñ":"n"
	}

	for a in acentos.keys():
		t = t.replace(a, acentos[a])

	while "  " in t:
		t = t.replace("  ", " ")

	return t


# ============================================================
# VALIDAR RESPUESTA
# ============================================================
func _on_btn_validar_pressed() -> void:

	for i in range(campos.size()):
		var u: String = normalizar(campos[i].text)
		var c: String = normalizar(respuestas_correctas[i])

		if u != c:
			retro.text = "❌ Incorrecto\nEsperada:\n" + respuestas_correctas[i]
			retro.modulate = Color.RED
			await get_tree().create_timer(1.2).timeout
			indice_actual += 1
			errores += 1
			if errores >= errores_maximos:
				fallar_demasiado()
				return 
				
			mostrar_pregunta()
			return

	retro.text = "✔ ¡Correcto!"
	retro.modulate = Color.GREEN

	await get_tree().create_timer(1.2).timeout
	indice_actual += 1
	mostrar_pregunta()


# ============================================================
# MOSTRAR PISTA (GATITO)
# ============================================================
func _mostrar_pista() -> void:
	if pistas_actuales.is_empty():
		return

	var texto: String = pistas_actuales.pop_front()

	var ventana := EscenaPista.instantiate()
	add_child(ventana)
	ventana.set_pista(texto)
