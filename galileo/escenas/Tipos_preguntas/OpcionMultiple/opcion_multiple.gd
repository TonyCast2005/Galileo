extends Control

@onready var http = $HTTPRequest
@onready var label_pregunta = $TextoPregunta
@onready var boton1 = $Opcion1
@onready var boton2 = $Opcion2
@onready var boton3 = $Opcion3

var preguntas: Array = []     # Todas las preguntas cargadas desde Firebase
var indice_actual: int = 0    # Pregunta actual
signal respondida(texto: String, color: Color, correcta: bool)

func _ready():
    # Conectar señal de HTTPRequest
    http.request_completed.connect(_on_request_completed)

    # Descargar preguntas desde Firebase
    var url = "https://galileo-af640-default-rtdb.firebaseio.com/examen_ubicacion.json"
    http.request(url)

    # Conectar la señal del padre Examen
    var examen = get_parent()  
    if examen.has_signal("siguiente_pregunta"):
        examen.connect("siguiente_pregunta", Callable(self, "_mostrar_siguiente_pregunta"))

# ===========================
# Respuesta del HTTPRequest
# ===========================
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
            mostrar_pregunta(indice_actual)
        else:
            label_pregunta.text = "⚠️ No hay preguntas disponibles"
    else:
        label_pregunta.text = "❌ Error al cargar preguntas"

# ===========================
# Mostrar la pregunta actual
# ===========================
func mostrar_pregunta(indice: int):
    if indice >= preguntas.size():
        label_pregunta.text = "🎉 Examen terminado"
        boton1.visible = false
        boton2.visible = false
        boton3.visible = false
        return

    var pregunta = preguntas[indice]
    label_pregunta.text = pregunta.get("pregunta", "Pregunta no encontrada")

    var opciones = pregunta.get("opciones", [])
    if opciones.size() < 3:
        print("⚠️ Pregunta inválida, faltan opciones:", opciones)
        return

    boton1.text = opciones[0]
    boton2.text = opciones[1]
    boton3.text = opciones[2]

    # Limpiar conexiones anteriores
    for s in boton1.pressed.get_connections():
        boton1.pressed.disconnect(s["callable"])
    for s in boton2.pressed.get_connections():
        boton2.pressed.disconnect(s["callable"])
    for s in boton3.pressed.get_connections():
        boton3.pressed.disconnect(s["callable"])

    # Conectar botones a la función responder
    var correcta = pregunta.get("respuesta_correcta", "")
    boton1.pressed.connect(func(): responder(opciones[0], correcta))
    boton2.pressed.connect(func(): responder(opciones[1], correcta))
    boton3.pressed.connect(func(): responder(opciones[2], correcta))

# ===========================
# Cambiar a la siguiente pregunta
# ===========================
func _mostrar_siguiente_pregunta():
    indice_actual += 1
    mostrar_pregunta(indice_actual)

# ===========================
# Verificar respuesta
# ===========================
func responder(respuesta: String, correcta: String):
    if respuesta == correcta:
        emit_signal("respondida", "✅ ¡Muy bien! Has acertado.", Color(0,1,0), true)
    else:
        emit_signal("respondida", "❌ Incorrecto... inténtalo otra vez.", Color(1,0,0), false)
