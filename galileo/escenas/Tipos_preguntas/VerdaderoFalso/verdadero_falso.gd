extends Control

# 🌟 1. Variable clave para el mapeo de métricas 🌟
# Definimos el tipo de ejercicio para el MetricsManager
const EXERCISE_TYPE = "VF" 

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

# Señal usada por el Contenedor (OpcMultiple_1.gd, etc.) para saber si se respondió.
# En este script, se puede eliminar si la escena lo gestiona todo.
signal respondida(correcta: bool)

func _ready():
    boton_v.pressed.connect(func(): _evaluar_respuesta(true))
    boton_f.pressed.connect(func(): _evaluar_respuesta(false))
    boton_pistas.pressed.connect(_mostrar_pista)
    
    _iniciar_animacion_botones()


    _cargar_preguntas()

# ===============================
# SISTEMA DE ERRORES
# ===============================
var errores: int = 0
var errores_maximos: int = 3   # Puedes ajustar libremente

func fallar_demasiado() -> void:
    Globals.repetir_bloque = true
    get_tree().change_scene_to_file("res://escenas/Tipos_preguntas/RepiteLeccion.tscn")
    
# ======================================================
#     CARGAR PREGUNTAS DESDE FIREBASE
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
#     MOSTRAR SIGUIENTE PREGUNTA
# ======================================================
func _mostrar_siguiente_pregunta():
    if preguntas_lista.is_empty():
        label_pregunta.text = "¡Has terminado!"
        
        # 🔴 FIX DE ERROR: Usar Globals.desbloqueados1 (o el array correcto)
        # Se asume que desbloqueados1 es el progreso del tema actual.
        # Se asume que Globals.bloque_actual es el índice de la siguiente lección a desbloquear.
        
        # Se asume que si bloque_actual es 2 (botón 2), al terminar se debe desbloquear la lección 3 (índice 3)
        var next_lesson_index = Globals.bloque_actual 

        if next_lesson_index >= 1 and next_lesson_index < Globals.desbloqueados1.size():
            # Desbloquea la siguiente lección
            Globals.desbloqueados1[next_lesson_index] = true
        else:
            print("AVISO: El índice a desbloquear está fuera de rango en Globals.desbloqueados1")
            
        get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")
        return

    var p = preguntas_lista.pop_front()
    set_pregunta(p)


# ======================================================
#              ASIGNAR DATOS
# ======================================================
func set_pregunta(data: Dictionary) -> void:
    pregunta_actual = data.duplicate(true)
    label_pregunta.text = data.get("pregunta", "Pregunta desconocida")


# ======================================================
#     EVALUAR RESPUESTA
# ======================================================
func _evaluar_respuesta(resp: bool):
    var correcta = resp == pregunta_actual["respuesta_correcta"]
    
    # 🌟 PASO CLAVE 1: ACTUALIZAR MÉTRICAS GLOBALES (ADAPTATIVAS) 🌟
    MetricsManager.update_methodology_score(EXERCISE_TYPE, correcta)
    
    emit_signal("respondida", correcta)
    
    if correcta:
        mensaje.text = "¡Correcto!"
        mensaje.modulate = Color.GREEN
    else:
        mensaje.text = "Incorrecto :("
        mensaje.modulate = Color.RED
        errores += 1 # Solo sumar error si es incorrecto
        
    if errores >= errores_maximos:
        fallar_demasiado()
        return 

    await get_tree().create_timer(1.2).timeout
    mensaje.text = ""

    _mostrar_siguiente_pregunta()


# ======================================================
#              MOSTRAR PISTA
# ======================================================
func _mostrar_pista():
    # Se debe verificar si el array de pistas existe y no está vacío
    if not pregunta_actual.has("pistas") or pregunta_actual["pistas"].is_empty():
        return

    var texto: String = str(pregunta_actual["pistas"].pop_front())

    var ventana = escena_pista.instantiate()
    add_child(ventana)
    ventana.set_pista(texto)


func _iniciar_animacion_botones():
    # Guardar posiciones originales
    var pos_v = boton_v.position
    var pos_f = boton_f.position

    # --- Tween para Verdadero (sube y baja) ---
    var tween_v = create_tween().set_loops()
    tween_v.tween_property(boton_v, "position:y", pos_v.y - 12, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween_v.tween_property(boton_v, "position:y", pos_v.y, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    # --- Tween para Falso (baja mientras V sube, y viceversa) ---
    var tween_f = create_tween().set_loops()
    tween_f.tween_property(boton_f, "position:y", pos_f.y + 12, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween_f.tween_property(boton_f, "position:y", pos_f.y, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
