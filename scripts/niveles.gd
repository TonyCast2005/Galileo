extends Control

@onready var contenedor_niveles = $ScrollContainer/VBoxContainer

var cantidad_de_niveles = 10
var nivel_escena = preload("res://scenes/nivel_nodo.tscn")

func _ready():
    for i in range(cantidad_de_niveles):
        var nivel = nivel_escena.instantiate()
        nivel.nombre_nivel = "Nivel %d" % (i + 1)
        nivel.numero_nivel = i + 1
        nivel.desbloqueado = i == 0  # Solo el primero desbloqueado
        contenedor_niveles.add_child(nivel)
