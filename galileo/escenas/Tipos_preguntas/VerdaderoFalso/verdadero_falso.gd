extends Control

@onready var campo_pregunta = $pregunta
@onready var campo_op1 = $Respuesta1
@onready var campo_op2 = $Respuesta2
@onready var campo_op3 = $Respuesta3
@onready var campo_correcta = $respuesta_correcta  # debe ser 1,2 o 3
@onready var mensaje = $Mensaje

var firebase
var editando_id = null

func _ready():
    firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
    add_child(firebase)

    if Globals.temp_preview_data:
        _fill_preview_data()


# =========================================================
# LLENAR DATOS SI VIENE PREVIEW
# =========================================================
func _fill_preview_data():
    var data = Globals.temp_preview_data
    if data.has("pregunta"):
        campo_pregunta.text = data["pregunta"]
    if data.has("opciones"):
        campo_op1.text = data["opciones"][0]
        campo_op2.text = data["opciones"][1]
        campo_op3.text = data["opciones"][2]
    if data.has("correcta"):
        campo_correcta.text = str(data["correcta"])


# =========================================================
# OBTENER DATOS DEL FORMULARIO
# =========================================================
func get_form_data(estado:String) -> Dictionary:
    return {
        "pregunta": campo_pregunta.text,
        "opciones": [campo_op1.text, campo_op2.text, campo_op3.text],
        "correcta": int(campo_correcta.text),
        "estado": estado
    }


# =========================================================
# GUARDAR
# =========================================================
func _on_guardar_pressed():

    var data = get_form_data("publicado")

    var res = await firebase.save_question_OPC(data)

    if res == null or res.has("error"):
        _show_message("Error al guardar :(", Color.RED)
    else:
        _show_message("Pregunta guardada correctamente", Color.GREEN)
        _clear_fields()


# =========================================================
# BORRADOR
# =========================================================
func _on_borrador_pressed():
    Globals.temp_preview_data = get_form_data("borrador")
    _show_message("Borrador guardado", Color(Color.DARK_ORANGE))
    _clear_fields()


# =========================================================
# ELIMINAR
# =========================================================
func _on_eliminar_pressed():
    if editando_id == null:
        _show_message("Nada que eliminar", Color.YELLOW)
        return

    var url = "%s/preguntas_opc/%s.json" % [firebase.DB_URL, editando_id]

    var http := HTTPRequest.new()
    add_child(http)
    await http.request(url, [], HTTPClient.METHOD_DELETE)
    http.queue_free()

    editando_id = null
    _clear_fields()
    _show_message("Pregunta eliminada", Color.RED)


# =========================================================
# PREVISUALIZAR
# =========================================================
func _on_previsualizar_pressed():
    Globals.temp_preview_data = get_form_data("preview")
    get_tree().change_scene_to_file("res://escenas/Administrador/preview_opcion_multiple.tscn")


# =========================================================
# MENSAJE TEMPORAL
# =========================================================
func _show_message(texto, color:Color):
    mensaje.text = texto
    mensaje.modulate = color
    mensaje.visible = true

    await get_tree().create_timer(4).timeout
    mensaje.visible = false


# =========================================================
# LIMPIAR FORMULARIO
# =========================================================
func _clear_fields():
    campo_pregunta.text = ""
    campo_op1.text = ""
    campo_op2.text = ""
    campo_op3.text = ""
    campo_correcta.text = ""
