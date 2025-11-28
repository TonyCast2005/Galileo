extends Control

@onready var panel = $ColorRect
@onready var iconloading = $AnimatedSprite2D

func _ready():
    # Panel fuera de pantalla para efecto inicial
    panel.position.x = -panel.size.x
    panel.modulate.a = 1.0  # aseguramos opacidad total para inicio
    iconloading.play()

func fade_in():
    var tween = get_tree().create_tween()
    tween.tween_property(panel, "position:x", 0, 0.5)\
        .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    return tween.finished

func fade_out():
    var tween = get_tree().create_tween()

    # ⬇️ en vez de mover el panel, ahora lo desvanecemos
    tween.tween_property(panel, "modulate:a", 0.0, 0.5)\
        .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

    return tween.finished
