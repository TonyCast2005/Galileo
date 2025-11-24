extends Control

@onready var niveles_container = $ScrollContainer/VBoxContainer
@onready var tema = $TemaLabel
@onready var scroll = $ScrollContainer
@onready var flecha = $Flecha   # <---- flecha en escena

var selector_scene = preload("res://escenas/usuario/MenuInicial/selectorNivel.tscn")

# 1. Rutas de escenas por nivel
var exercise_scenes: Dictionary = {
    1: "res://escenas/Tipos_preguntas/Lectura/Lectura.tscn",
    2: "res://escenas/ejercicios/ejercicio_02_arrastrar_soltar.tscn",
    3: "res://escenas/ejercicios/ejercicio_03_preguntas_abiertas.tscn",
    4: "res://escenas/ejercicios/ejercicio_04_otro_tipo.tscn",
    12: "res://escenas/ejercicios/ejercicio_12_final.tscn",
}

# 2. Tema por nivel
var temas_por_nivel := {
    1: "Introducción a Arduino",
    2: "Variables y Datos",
    3: "Entradas Digitales",
    4: "Salidas Digitales",
    5: "PWM y LEDs",
    6: "Sensores Analógicos",
    7: "Motores",
    8: "Comunicaciones",
    9: "Temporizadores",
    10: "Interrupciones",
    11: "Práctica Final",
    12: "Proyecto Final",
}

@export var total_niveles : int = 12
@export var nivel_desbloqueado_global : int = 1


func _ready():
    _crear_niveles()
    scroll.get_v_scroll_bar().value_changed.connect(_on_scroll_changed)
    _on_scroll_changed(0) # Primera actualización


func _crear_niveles():
    for child in niveles_container.get_children():
        child.queue_free()
    
    for i in range(total_niveles):
        var boton = selector_scene.instantiate() as SelectorNivel
        boton.level_num = i + 1
        boton.locked = i + 1 > nivel_desbloqueado_global

        boton.custom_minimum_size = Vector2(150, 50)

        boton.level_selected.connect(_on_level_selected)
        niveles_container.add_child(boton)


func _on_level_selected(level: int):
    var scene_path = exercise_scenes.get(level)
    if scene_path:
        get_tree().change_scene_to_file(scene_path)
    else:
        push_error("No hay escena para nivel " + str(level))


# --- 4. Flecha sincronizada con scroll ---
func _on_scroll_changed(value: float):
    var botones = niveles_container.get_children()
    if botones.size() == 0:
        return

    var scroll_top = scroll.global_position.y
    var scroll_bottom = scroll_top + scroll.size.y
    var scroll_center = scroll_top + scroll.size.y / 2.0

    var mejor_boton = null
    var mejor_distancia = INF

    # Buscar el botón más cercano al centro del scroll
    for boton in botones:
        var boton_center = boton.global_position.y + boton.size.y / 2.0
        var distancia = abs(boton_center - scroll_center)

        if distancia < mejor_distancia:
            mejor_distancia = distancia
            mejor_boton = boton

    if mejor_boton == null:
        return

    # Cambiar tema según el botón detectado
    var lvl = mejor_boton.level_num
    tema.text = temas_por_nivel.get(lvl, "Tema no definido")

    # Mover flecha encima del botón detectado
    var boton_pos = mejor_boton.global_position
    
    flecha.global_position.x = boton_pos.x - 50   # Ajusta para poner la flecha a la izquierda
    flecha.global_position.y = boton_pos.y - 20   # Ajusta para que quede encima del botón
