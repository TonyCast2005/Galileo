extends Control

@onready var http = $HTTPRequestFirebase
@onready var pregunta_label = $CenterContainer/VBoxContainer/Pregunta
@onready var opciones_container = $CenterContainer/VBoxContainer/opciones_contenedor

func _ready():
    http.request_completed.connect(_on_request_completed)
    var url = "https://galileo-af640-default-rtdb.firebaseio.com/preguntas.json"
    http.request(url)

func _on_request_completed(result, response_code, headers, body):
    if response_code != 200:
        pregunta_label.text = "Error al cargar pregunta"
        return

    var data = JSON.parse_string(body.get_string_from_utf8())
    if data == null:
        pregunta_label.text = "Error al leer JSON"
        return

    # Cargar una sola pregunta por prueba
    var pregunta = data.get("pregunta1", null)
    if pregunta == null:
        pregunta_label.text = "No se encontró pregunta"
        return

    # Mostrar pregunta
    pregunta_label.text = pregunta["texto"]

    # Mostrar opciones como botones
    for opcion in pregunta["opciones"]:
        var boton = Button.new()
        boton.text = opcion
        boton.pressed.connect(func():
            if opcion == pregunta["respuesta_correcta"]:
                pregunta_label.text = "¡Correcto!"
            else:
                pregunta_label.text = "Incorrecto. Intenta de nuevo."
        )
        opciones_container.add_child(boton)
