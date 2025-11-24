extends Control

@onready var label_pregunta = $TextoPregunta
@onready var boton1 = $Opcion1
@onready var boton2 = $Opcion2
@onready var boton3 = $Opcion3
@onready var titulo = $NombreLeccion

signal respondida(texto: String, color: Color, correcta: bool)

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
