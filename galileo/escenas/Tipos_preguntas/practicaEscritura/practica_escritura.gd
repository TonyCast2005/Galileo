extends Control

@onready var lbl_enunciado: Label = $Enunciado
@onready var lbl_codigo: Label = $Codigo
@onready var cont_campos: VBoxContainer = $Campos
@onready var retro: Label = $Retro
@onready var btn_pista: Button = $Pista

var EscenaPista: PackedScene = preload("res://escenas/Pistas/Pistas_Contenedor.tscn")

var preguntas: Array = []
var indice_actual: int = 0
var respuestas_correctas: Array = []
var campos: Array = []
var pistas: Array = []

const FIREBASE_URL: String = "https://galileo-af640-default-rtdb.firebaseio.com/practica_escritura.json"


func _ready() -> void:
	cargar_preguntas()
	btn_pista.pressed.connect(_mostrar_pista)


# ============================================================
# CARGAR TODAS LAS PREGUNTAS
# ============================================================
func cargar_preguntas() -> void:
	var http := HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(_on_request_completed)
	http.request(FIREBASE_URL)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:

	if response_code != 200:
		lbl_enunciado.text = "Error al conectar con Firebase"
		return

	var texto: String = body.get_string_from_utf8()
	var data := JSON.parse_string(texto)

	if typeof(data) == TYPE_DICTIONARY:
		for key in data.keys():
			var p := data[key]
			if typeof(p) == TYPE_DICTIONARY:
				preguntas.append(p)

	elif typeof(data) == TYPE_ARRAY:
		for p in data:
			if typeof(p) == TYPE_DICTIONARY:
				preguntas.append(p)

	if preguntas.is_empty():
		lbl_enunciado.text = "No hay preguntas disponibles."
		return

	mostrar_pregunta(0)


# ============================================================
# MOSTRAR PREGUNTA
# ============================================================
func mostrar_pregunta(i: int) -> void:

	if i >= preguntas.size():
		lbl_enunciado.text = "¡Felicidades! Terminaste todas las prácticas."
		cont_campos.visible = false
		lbl_codigo.visible = false
		btn_pista.visible = false
		return

	var pregunta: Dictionary = preguntas[i]

	lbl_enunciado.text = pregunta.get("enunciado", "Sin enunciado")
	lbl_codigo.text = pregunta.get("plantilla", "")

	# Respuestas correctas
	respuestas_correctas = pregunta.get("respuestas_correctas", [])

	# Pistas con tipado correcto
	var p_tmp := pregunta.get("pistas", [])
	pistas = p_tmp.duplicate()

	# Cantidad de campos
	var cantidad: int = pregunta.get("campos", respuestas_correctas.size())

	# Borrar anteriores
	for c in cont_campos.get_children():
		c.queue_free()

	campos.clear()

	for k in range(cantidad):
		var input := LineEdit.new()
		input.placeholder_text = "Respuesta " + str(k + 1)
		cont_campos.add_child(input)
		campos.append(input)

	retro.text = ""
	retro.modulate = Color.WHITE

	btn_pista.visible = pistas.size() > 0


# ============================================================
# NORMALIZAR
# ============================================================
func normalizar(s: String) -> String:
	var t: String = s.to_lower().strip_edges()

	var acentos := {
		"á":"a","é":"e","í":"i","ó":"o","ú":"u",
		"ä":"a","ë":"e","ï":"i","ö":"o","ü":"u",
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
		var user: String = normalizar(campos[i].text)
		var correct: String = normalizar(respuestas_correctas[i])

		if user != correct:
			retro.text = "❌ Incorrecto\nRespuesta esperada:\n" + respuestas_correctas[i]
			retro.modulate = Color.RED

			await get_tree().create_timer(1.2).timeout
			indice_actual += 1
			mostrar_pregunta(indice_actual)
			return

	retro.text = "✔ Correcto"
	retro.modulate = Color.GREEN

	await get_tree().create_timer(1.2).timeout
	indice_actual += 1
	mostrar_pregunta(indice_actual)


# ============================================================
# MOSTRAR PISTA
# ============================================================
func _mostrar_pista() -> void:

	if pistas.is_empty():
		return

	var texto_pista: String = String(pistas.pop_front())

	var ventana := EscenaPista.instantiate()
	add_child(ventana)

	ventana.set_pista(texto_pista)
