extends Control

@onready var lbl_enunciado = $Enunciado
@onready var lbl_codigo = $Codigo
@onready var cont_campos = $Campos
@onready var retro = $Retro
@onready var btn_validar = $btn_validar

var respuestas_correctas = []
var campos = []
var pregunta_actual = {}

func _ready():
	var ejemplo = {
		"tipo": "llenar_codigo",
		"enunciado": "Completa el delay:",
		"plantilla": "delay(___ );",
		"campos": 1,
		"respuestas_correctas": ["1000"]
	}

	cargar_pregunta(ejemplo)

# =====================================================================
# CARGAR PREGUNTA DESDE UN DICCIONARIO
# =====================================================================
func cargar_pregunta(data: Dictionary):
	print("\n===== CARGANDO PREGUNTA =====")
	print("Data recibida:", data)

	# Seguridad por si algún campo no existe
	if not data.has("enunciado"):
		push_error("ERROR: La pregunta no tiene 'enunciado'")
		return
	if not data.has("plantilla"):
		push_error("ERROR: La pregunta no tiene 'plantilla'")
		return
	if not data.has("respuestas_correctas"):
		push_error("ERROR: No tiene 'respuestas_correctas'")
		return
	if not data.has("campos"):
		push_error("ERROR: No tiene 'campos'")
		return

	pregunta_actual = data

	lbl_enunciado.text = data["enunciado"]
	lbl_codigo.text = data["plantilla"]
	respuestas_correctas = data["respuestas_correctas"]

	print("Enunciado:", lbl_enunciado.text)
	print("Código mostrado:", lbl_codigo.text)
	print("Respuestas correctas:", respuestas_correctas)
	print("Cantidad de campos:", data["campos"])

	# -----------------------------------------------------------------
	# LIMPIAR CAMPOS ANTERIORES
	# -----------------------------------------------------------------
	for c in cont_campos.get_children():
		c.queue_free()
	campos.clear()

	# -----------------------------------------------------------------
	# CREAR CAMPOS SEGÚN LA PREGUNTA
	# -----------------------------------------------------------------
	for i in range(data["campos"]):
		var input = LineEdit.new()
		input.placeholder_text = "Respuesta " + str(i + 1)
		cont_campos.add_child(input)
		campos.append(input)

	print("Campos creados:", campos)

	retro.text = ""
	retro.modulate = Color.WHITE

	print("✔ Pregunta cargada correctamente.")


# =====================================================================
# VALIDAR RESPUESTAS
# =====================================================================
func _on_btn_validar_pressed():
	print("\n===== VALIDANDO =====")

	if campos.size() == 0:
		retro.text = "No hay campos para validar."
		retro.modulate = Color.RED
		print("ERROR: No se cargaron campos.")
		return

	if respuestas_correctas.size() != campos.size():
		print("ERROR: Tamaño de respuestas no coincide.")
		retro.text = "Error interno: respuestas no coinciden."
		retro.modulate = Color.RED
		return

	# Verificar uno por uno
	for i in range(campos.size()):
		var user = campos[i].text.strip_edges()
		var correct = respuestas_correctas[i]

		print("Campo", i, ": usuario =", user, " | correcto =", correct)

		if user != correct:
			retro.text = "Incorrecto"
			retro.modulate = Color.RED
			return

	retro.text = "Correcto"
	retro.modulate = Color.GREEN
	print("✔ Respuesta correcta")
