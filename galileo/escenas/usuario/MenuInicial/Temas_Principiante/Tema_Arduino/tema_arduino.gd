extends Control

# Candados (íconos de bloqueo)
@onready var candado2 = $Panel/VBoxContainer/Button2/TextureRect2
@onready var candado3 = $Panel/VBoxContainer/Button3/TextureRect3
@onready var candado4 = $Panel/VBoxContainer/Button4/TextureRect4

# Lista de botones para poder iterar fácilmente
@onready var botones = [
    $Panel/VBoxContainer/Button1,
    $Panel/VBoxContainer/Button2,
    $Panel/VBoxContainer/Button3,
    $Panel/VBoxContainer/Button4
]

# Lista de candados para sincronizar
var candados := []

# Control de desbloqueo: cuántos botones están desbloqueados
var max_desbloqueado := 1

# Botón 1 siempre es lectura
var escena_lectura := "res://escenas/Tipos_preguntas/Lectura/Lectura.tscn"

# Ejercicios disponibles para Arduino (principiantes)
var ejercicios_arduino := [
    {"tipo": "OpcionMultiple", "ruta": "res://escenas/Tipos_preguntas/OpcionMultiple/OpcionMultiple.tscn"},
    {"tipo": "VerdaderoFalso", "ruta": "res://escenas/Tipos_preguntas/VerdaderoFalso/VF.tscn"},
    {"tipo": "OpcionMultiple", "ruta": "res://escenas/Tipos_preguntas/OpcionMultiple/OpcionMultiple2.tscn"},
]

func _ready():
    # Guardamos los candados en orden
    candados = [null, candado2, candado3, candado4]  # null para botón 1
    _actualizar_estado_botones()
    randomize() # Para que randi() genere aleatorios distintos cada ejecución

# ----------------------------
# Actualiza botones y candados según max_desbloqueado
# ----------------------------
func _actualizar_estado_botones():
    for i in range(botones.size()):
        if i < max_desbloqueado:
            botones[i].disabled = false
            if candados[i]:
                candados[i].visible = false
        else:
            botones[i].disabled = true
            if candados[i]:
                candados[i].visible = true

# ----------------------------
# Función para avanzar al siguiente nivel (desbloquear)
# ----------------------------
func desbloquear_siguiente():
    if max_desbloqueado < botones.size():
        max_desbloqueado += 1
        _actualizar_estado_botones()

# ----------------------------
# Función para escoger un ejercicio aleatorio
# ----------------------------
func ejercicio_aleatorio() -> Dictionary:
    var indice = randi() % ejercicios_arduino.size()
    return ejercicios_arduino[indice]

# ----------------------------
# Función para cargar escena de ejercicio
# ----------------------------
func cargar_escena_ejercicio(ejercicio: Dictionary) -> void:
    var escena = load(ejercicio.ruta).instantiate()
    get_tree().current_scene.add_child(escena)

    # Si la escena tiene un método para recibir la pregunta desde Firebase
    if escena.has_method("set_pregunta"):
        var preguntas = Globals.preguntas_arduino   # Lista de preguntas cargadas previamente
        if preguntas.size() > 0:
            var pregunta = preguntas[randi() % preguntas.size()]
            escena.set_pregunta(pregunta)


# ----------------------------
# Funciones de los botones
# ----------------------------
func _on_button_1_pressed() -> void:
    get_tree().change_scene_to_file(escena_lectura)
    desbloquear_siguiente()

func _on_button_2_pressed() -> void:
    var ejercicio = ejercicio_aleatorio()
    cargar_escena_ejercicio(ejercicio)
    desbloquear_siguiente()

func _on_button_3_pressed() -> void:
    var ejercicio = ejercicio_aleatorio()
    cargar_escena_ejercicio(ejercicio)
    desbloquear_siguiente()

func _on_button_4_pressed() -> void:
    var ejercicio = ejercicio_aleatorio()
    cargar_escena_ejercicio(ejercicio)
    desbloquear_siguiente()
