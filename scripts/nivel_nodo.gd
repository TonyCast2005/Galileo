extends Button

@export var nombre_nivel = "Nivel 1"
@export var numero_nivel = 1
@export var desbloqueado = false

func _ready():
    text = nombre_nivel
    if desbloqueado:
        disabled = false
        modulate = Color.WHITE
    else:
        disabled = true
        modulate = Color(0.5, 0.5, 0.5, 1)  # Gris
