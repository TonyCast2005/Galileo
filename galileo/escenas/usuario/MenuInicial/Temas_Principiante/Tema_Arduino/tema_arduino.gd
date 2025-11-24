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

# Rutas de escenas por botón
var escenas := [
    "res://escenas/tema1/lectura.tscn",
    "res://escenas/tema1/ejercicio2.tscn",
    "res://escenas/tema1/ejercicio3.tscn",
    "res://escenas/tema1/ejercicio4.tscn"
]

func _ready():
    # Guardamos los candados en orden
    candados = [null, candado2, candado3, candado4]  # null para botón 1
    _actualizar_estado_botones()

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
# Funciones de los botones
# ----------------------------
func _on_button_1_pressed() -> void:
    get_tree().change_scene_to_file(escenas[0])
    desbloquear_siguiente()

func _on_button_2_pressed() -> void:
    get_tree().change_scene_to_file(escenas[1])
    desbloquear_siguiente()

func _on_button_3_pressed() -> void:
    get_tree().change_scene_to_file(escenas[2])
    desbloquear_siguiente()

func _on_button_4_pressed() -> void:
    get_tree().change_scene_to_file(escenas[3])
    desbloquear_siguiente()
