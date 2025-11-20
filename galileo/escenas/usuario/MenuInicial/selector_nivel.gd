extends Button
class_name SelectorNivel

## ----------------------------------------------------
## 1. Declaración de Señal
## Esta señal se emite cuando el botón es presionado (y no está bloqueado).
## El menú principal se conectará a esta señal para saber qué nivel cargar.
signal level_selected(level: int)
## ----------------------------------------------------

@export var level_num: int = 1

@export var locked: bool = true:
    set(value):
        locked = value
        _update_state()

@onready var level_label: Label = $Label
@onready var icon_node: TextureRect = $bloqueado

# Preload para texturas (Asegúrate de que estas rutas sean correctas)
var tex_locked: Texture = preload("res://assets/sprites/ui/bloqueado.png")
var tex_unlocked: Texture = preload("res://assets/sprites/ui/moradoC.png")

func _ready():
    _update_state()

func _update_state():
    if level_label == null or icon_node == null:
        # En Godot 4, es mejor usar is_instance_valid() o comprobar el onready
        return

    if locked:
        level_label.visible = false
        icon_node.texture = tex_locked
        disabled = true # Deshabilita el botón si está bloqueado
    else:
        level_label.visible = true
        level_label.text = str(level_num)
        icon_node.texture = tex_unlocked
        disabled = false # Habilita el botón si está desbloqueado

func _pressed():
    if not locked:
        print("Nivel ", level_num, " seleccionado")
        
        ## ----------------------------------------------------
        ## 2. Emisión de la Señal
        ## Dispara el evento y pasa el número de nivel al script padre (el menú).
        emit_signal("level_selected", level_num)
        ## ----------------------------------------------------
