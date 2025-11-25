extends Control

@onready var label_pregunta = $TextoPregunta
@onready var boton_v = $Verdadero
@onready var boton_f = $Falso
@onready var boton_pistas = $Pista
@onready var http := $HTTPRequest
@onready var mensaje := $Mensaje 

# Preload escena de pistas
var escena_pista := preload("res://escenas/Pistas/Pistas_Contenedor.tscn")

var pregunta_actual: Dictionary = {
    "pregunta": "",
    "respuesta_correcta": true,
    "pistas": []
}

var preguntas_lista: Array = []

signal respondida(correcta: bool)

func _ready():
    boton_v.pressed.connect(func(): _evaluar_respuesta(true))
    boton_f.pressed.connect(func(): _evaluar_respuesta(false))
    boton_pistas.pressed.connect(_mostrar_pista)

    _cargar_preguntas()


# ======================================================
#       CARGAR PREGUNTAS DESDE FIREBASE
# ======================================================
func _cargar_preguntas():
    var url = "https://galileo-af640-default-rtdb.firebaseio.com/preguntas_arduino_vf.json"
    http.request(url)

func _on_http_request_request_completed(result, response_code, headers, body):
    if response_code != 200:
        print("Error al cargar preguntas: ", response_code)
        return

    var datos = JSON.parse_string(body.get_string_from_utf8())
    if typeof(datos) != TYPE_DICTIONARY:
        print("Formato incorrecto en Firebase")
        return

    # Convertir diccionario en array
    preguntas_lista = datos.values()

    # Seleccionar solo 4 preguntas aleatorias
    var temp = preguntas_lista.duplicate()
    temp.shuffle()
    preguntas_lista = temp.slice(0, 4)

    _mostrar_siguiente_pregunta()


# ======================================================
#         MOSTRAR SIGUIENTE PREGUNTA
# ======================================================
func _mostrar_siguiente_pregunta():
    if preguntas_lista.is_empty():
        label_pregunta.text = "¡Has terminado!"
        get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")
        return

    var p = preguntas_lista.pop_front()
    set_pregunta(p)


# ======================================================
#                ASIGNAR DATOS
# ======================================================
func set_pregunta(data: Dictionary) -> void:
    pregunta_actual = data.duplicate(true)
    label_pregunta.text = data.get("pregunta", "Pregunta desconocida")


# ======================================================
#          EVALUAR RESPUESTA
# ======================================================
func _evaluar_respuesta(resp: bool):
    var correcta = resp == pregunta_actual["respuesta_correcta"]
    emit_signal("respondida", correcta)
    
    if correcta:
        mensaje.text = "¡Correcto!"
        mensaje.modulate = Color.GREEN
    else:
        mensaje.text = "Incorrecto :("
        mensaje.modulate = Color.RED

    await get_tree().create_timer(1.2).timeout
    mensaje.text = ""

    _mostrar_siguiente_pregunta()


# ======================================================
#                MOSTRAR PISTA
# ======================================================
func _mostrar_pista():
    if pregunta_actual["pistas"].is_empty():
        return

    var texto: String = str(pregunta_actual["pistas"].pop_front())

    var ventana = escena_pista.instantiate()
    add_child(ventana)
    ventana.set_pista(texto)
