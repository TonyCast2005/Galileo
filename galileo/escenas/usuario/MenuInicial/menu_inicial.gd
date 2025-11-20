extends Control

@onready var levels_container = $ScrollContainer/VBoxContainer
var tema_card_scene = preload("res://escenas/usuario/MenuInicial/tema_card.tscn")

func _ready():
    for i in range(4):
        var card = tema_card_scene.instantiate()

        card.titulo_tema = "Tema " + str(i + 1)
        card.estado_texto = str(i % 2) + " / 2"
        #card.icono_texture = load("res://icons/arduino.png")
        card.color_fondo = Color(0.4 + i * 0.1, 0.6, 1.0 - i * 0.1)

        levels_container.add_child(card)
