extends Control

@onready var label_pregunta = $TextoPregunta
@onready var boton1 = $Opcion1
@onready var boton2 = $Opcion2
@onready var boton3 = $Opcion3
@onready var titulo = $NombreLeccion

signal respondida(texto: String, color: Color, correcta: bool)

var posiciones_originales = []


func _ready():
    # Guardamos las posiciones donde están en el editor (centro correcto)
    posiciones_originales = [
        boton1.position,
        boton2.position,
        boton3.position
    ]

    animar_entrada()


func set_pregunta(pregunta: Dictionary) -> void:
    label_pregunta.text = pregunta.get("pregunta", "Pregunta no encontrada")
    
    var opciones = pregunta.get("opciones", [])
    if opciones.size() < 3:
        print("Pregunta inválida, faltan opciones:", opciones)
        return
    
    boton1.text = opciones[0]
    boton2.text = opciones[1]
    boton3.text = opciones[2]
    
    # Desconectar conexiones anteriores
    for s in boton1.pressed.get_connections():
        boton1.pressed.disconnect(s["callable"])
    for s in boton2.pressed.get_connections():
        boton2.pressed.disconnect(s["callable"])
    for s in boton3.pressed.get_connections():
        boton3.pressed.disconnect(s["callable"])
    
    var correcta = pregunta.get("respuesta_correcta", "")
    
    boton1.pressed.connect(func(): responder(opciones[0], correcta))
    boton2.pressed.connect(func(): responder(opciones[1], correcta))
    boton3.pressed.connect(func(): responder(opciones[2], correcta))

# ===========================
# Verificar respuesta
# ===========================
func responder(respuesta: String, correcta: String):
    if respuesta == correcta:
        emit_signal("respondida", "¡Muy bien! Has acertado.", Color(0, 1, 0), true)
    else:
        emit_signal("respondida", "Incorrecto... inténtalo otra vez.", Color(1, 0, 0), false)
        
        
func animar_entrada():
    var botones = [boton1, boton2, boton3]

    for i in range(botones.size()):
        var b = botones[i]

        # Tomamos la posición correcta desde el editor
        var final_x = posiciones_originales[i].x

        # Los mandamos fuera de pantalla
        b.position.x = -700
        b.modulate.a = 0.0

        var t = create_tween()

        # ANIMACIÓN HACIA LA POSICIÓN ORIGINAL
        t.tween_property(b, "position:x", final_x, 0.4).set_delay(i * 0.1) \
            .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

        t.parallel().tween_property(b, "modulate:a", 1.0, 0.3).set_delay(i * 0.1)

        if i == botones.size() - 1:
            t.finished.connect(animar_flotacion)

func animar_flotacion():
    var botones = [boton1, boton2, boton3]

    for i in range(botones.size()):
        var b = botones[i]

        # Guardamos su posición original
        var base_y = b.position.y
        
        # Tween infinito
        var t = create_tween()
        t.set_loops()  # infinito

        # Subir más (movimiento más visible)
        t.tween_property(b, "position:y", base_y - 15, 1.8 + i * 0.3) \
    .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Bajar
        t.tween_property(b, "position:y", base_y, 1.8 + i * 0.3) \
    .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
