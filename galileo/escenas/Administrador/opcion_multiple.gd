extends Control

@onready var pregunta = $pregunta
@onready var r1 = $"Respuesta 1"
@onready var r2 = $"Respuesta 2"
@onready var r3 = $"Respuesta 3"
@onready var correcta = $Correcta
@onready var mensaje = $Mensaje

var firebase

func _ready():
	firebase = load("res://escenas/Administrador/FirebaseDB.gd").new()
	add_child(firebase)


func _on_guardar_pressed():
	var enunciado = String(pregunta.text).strip_edges()
	var op1 = String(r1.text).strip_edges()
	var op2 = String(r2.text).strip_edges()
	var op3 = String(r3.text).strip_edges()
	var correcta_num = String(correcta.text).strip_edges()  # 🔥 AQUÍ ESTABA EL ERROR

	# --- VALIDACIONES ---
	if enunciado.is_empty() or op1.is_empty() or op2.is_empty() or op3.is_empty():
		mensaje.text = "Llena todos los campos."
		return

	if correcta_num not in ["1", "2", "3"]:
		mensaje.text = "La respuesta correcta debe ser 1, 2 o 3."
		return

	# --- FORMATO FINAL PARA FIREBASE ---
	var data = {
		"pregunta": enunciado,
		"opcion1": op1,
		"opcion2": op2,
		"opcion3": op3,
		"correcta": int(correcta_num)   # Se guarda como número
	}

	var result = await firebase.save_question_OPC(data)

	# --- RESPUESTAS ---
	if result == null or result.has("error"):
		mensaje.text = "Error al guardar."
		print("Error Firebase:", result)
	else:
		mensaje.text = "Pregunta guardada correctamente."
		print("Guardado:", result)

# ======================================================
#          PREVISUALIZAR
# ======================================================
func _on_previsualizar_pressed():
	var enunciado = String(pregunta.text).strip_edges()
	var op1 = String(r1.text).strip_edges()
	var op2 = String(r2.text).strip_edges()
	var op3 = String(r3.text).strip_edges()
	var correcta_num = String(correcta.text).strip_edges()

	Globals.temp_preview_data = {
		"pregunta": enunciado,
		"opcion1": op1,
		"opcion2": op2,
		"opcion3": op3,
		"correcta": int(correcta_num)
	}

	get_tree().change_scene_to_file("res://escenas/Administrador/preview_opcion_multiple.tscn")

# ======================================================
#          GUARDAR COMO BORRADOR
# ======================================================
func _on_borrador_pressed():
	Globals.temp_preview_data = {
		"pregunta": pregunta.text,
		"opcion1": r1.text,
		"opcion2": r2.text,
		"opcion3": r3.text,
		"correcta": correcta.text
	}
	mensaje.text = "Borrador guardado"

# ======================================================
#          ELIMINAR (vacía campos)
# ======================================================
func _on_eliminar_pressed():
	_limpiar_campos()

# ======================================================
#          LIMPIAR CAMPOS
# ======================================================
func _limpiar_campos():
	pregunta.text = ""
	r1.text = ""
	r2.text = ""
	r3.text = ""
	correcta.text = ""

func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/AgregarPregunta.tscn")
