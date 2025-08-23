extends HBoxContainer

@onready var icono = $Icono         # Asegúrate de que sea un TextureRect llamado 'Icono'
@onready var nombre = $Nombre       # Asegúrate de que sea un Label llamado 'Nombre'

func configurar_logro(nombre_texto: String, desbloqueado: bool):
    nombre.text = nombre_texto

    # Cargar imagen del logro (cambia la ruta según tu imagen real)
    icono.texture = load("res://assets/icono_logro.png")
    icono.expand = true
    icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icono.custom_minimum_size = Vector2(64, 64)

    # Si está bloqueado, se ve semitransparente
    if desbloqueado:
        icono.modulate = Color(1, 1, 1, 1)       # Color normal
    else:
        icono.modulate = Color(1, 1, 1, 0.3)     # Transparente
