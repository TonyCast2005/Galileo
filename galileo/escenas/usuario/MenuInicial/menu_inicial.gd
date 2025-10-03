extends Control

@onready var levels_container = $ScrollContainer/VBoxContainer
var level_scene = preload("res://escenas/usuario/Perfil/selectorNivel.tscn")

func _ready():
    for i in range(10):
        var level = level_scene.instantiate()
        level.level_num = i + 1
        level.locked = (i != 0)
        levels_container.add_child(level)
