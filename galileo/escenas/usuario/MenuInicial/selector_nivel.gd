extends Button
class_name SelectorNivel  

@export var level_num: int = 1

@export var locked: bool = true:
    set(value):
        locked = value
        _update_state()

@onready var level_label: Label = $Label
@onready var icon_node: TextureRect = $bloqueado

var tex_locked: Texture = preload("res://assets/sprites/ui/bloqueado.png")
var tex_unlocked: Texture = preload("res://assets/sprites/ui/moradoC.png")

func _ready():
    if level_label == null:
        push_error("level_label es null! Revisa el nombre del nodo Label")
    if icon_node == null:
        push_error("icon_node es null! Revisa el nombre del nodo TextureRect")
    _update_state()

func _update_state():

    if level_label == null or icon_node == null:
        return

    if locked:
        level_label.visible = false
        icon_node.texture = tex_locked
        disabled = true
    else:
        level_label.visible = true
        level_label.text = str(level_num)
        icon_node.texture = tex_unlocked
        disabled = false

func _pressed():
    if not locked:
        print("Nivel", level_num, "seleccionado")
