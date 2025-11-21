extends Control

@onready var niveles_container = $ScrollContainer/VBoxContainer
var selector_scene = preload("res://escenas/usuario/MenuInicial/selectorNivel.tscn")

# 1. Mapeo de Niveles a Escenas de Ejercicios
# IMPORTANTE: Debes reemplazar los paths a la derecha (e.g., "res://...") 
# con las rutas reales de tus escenas de ejercicios de Godot (.tscn).
var exercise_scenes: Dictionary = {
    1: "res://escenas/Tipos_preguntas/Lectura/Lectura.tscn",
    2: "res://escenas/ejercicios/ejercicio_02_arrastrar_soltar.tscn",
    3: "res://escenas/ejercicios/ejercicio_03_preguntas_abiertas.tscn",
    4: "res://escenas/ejercicios/ejercicio_04_otro_tipo.tscn",
    # Continúa agregando las rutas para el resto de tus niveles (hasta el 12)
    # ...
    12: "res://escenas/ejercicios/ejercicio_12_final.tscn",
}

# Número total de niveles
@export var total_niveles : int = 12

# Último nivel desbloqueado (usado para la lógica de bloqueo/desbloqueo)
@export var nivel_desbloqueado_global : int = 1

func _ready():
    
    nivel_desbloqueado_global = Globals.nivel_desbloqueado
    _crear_niveles()



func _crear_niveles():
    if niveles_container == null:
        push_error("niveles_container no encontrado. Revisa la ruta en @onready.")
        return

    # Limpiar botones previos
    for child in niveles_container.get_children():
        child.queue_free()
    
    for i in range(total_niveles):
        # Instanciar el botón y usar el 'class_name' para un mejor tipado
        var boton = selector_scene.instantiate() as SelectorNivel 

        boton.level_num = i + 1

        # Lógica de desbloqueo
        boton.locked = i + 1 > nivel_desbloqueado_global

        # Tamaño y centrado
        boton.custom_minimum_size = Vector2(150, 50)
        boton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

        ## ----------------------------------------------------
        ## 2. Conexión de la Señal
        ## Conecta la señal 'level_selected' del botón a la función local 
        ## '_on_level_selected'.
        boton.level_selected.connect(_on_level_selected)
        ## ----------------------------------------------------

        niveles_container.add_child(boton)


## ----------------------------------------------------
## 3. Función para Manejar la Carga de Escena
## Esta función se ejecuta cuando se presiona un botón.
func _on_level_selected(level: int):
    # Busca la ruta de la escena en el diccionario usando el número de nivel
    var scene_path = exercise_scenes.get(level)
    Globals.set("nivel_actual", level)

    
    if scene_path:
        print("Cargando nivel ", level, ": ", scene_path)
        # Cambia la escena actual por la escena del ejercicio
        get_tree().change_scene_to_file(scene_path)
    else:
        push_error("¡ERROR! No hay una ruta de escena definida para el Nivel: " + str(level) + ". Revisa el diccionario 'exercise_scenes'.")
## ----------------------------------------------------
