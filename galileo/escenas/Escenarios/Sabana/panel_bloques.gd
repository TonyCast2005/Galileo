extends Control

func _ready():
    visible = false  # el panel comienza oculto

func abrir():
    visible = true

func cerrar():
    visible = false

func alternar():
    visible = not visible
