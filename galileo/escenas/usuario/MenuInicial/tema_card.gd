extends Control

@onready var tema = $Panel/tema
@onready var estado = $Panel/estado
@onready var icono = $Panel/icono
@onready var color_rect = $Panel/ColorRect

# Propiedades configurables desde afuera
@export var titulo_tema : String = "Tema"
@export var estado_texto : String = "0 / 2"
@export var icono_texture : Texture2D
@export var color_fondo : Color = Color(1, 1, 1)

func _ready():
    _actualizar_visuales()

func _actualizar_visuales():
    # título
    if tema:
        tema.text = titulo_tema
    
    # texto de estado (por ejemplo "1/2 lecciones")
    if estado:
        estado.text = estado_texto
    
    # icono del tema
    if icono and icono_texture:
        icono.texture = icono_texture
    
    # color del fondo
    if color_rect:
        color_rect.color = color_fondo
