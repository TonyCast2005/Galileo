extends Control

@onready var animacion = $AnimatedSprite2D


func _ready():
    # 1. Asegúrate de que el AnimatedSprite2D tenga un SpriteFrames asignado.
    
    # 2. Usa el método 'play()' para iniciar la animación.
    #    Si solo tienes una animación (la 'default'), puedes llamarlo sin argumentos.
    animacion.play()
    
    # Si tu animación tiene un nombre específico (ej: "correr"), úsalo:
    # animacion.play("correr")
