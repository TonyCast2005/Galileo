extends Control

@onready var panel = $ColorRect
@onready var iconloading = $AnimatedSprite2D

func _ready():
    panel.position.x = -panel.size.x

func fade_in():
    iconloading.play()  # inicia animación de carga
    var tween = get_tree().create_tween()
    tween.tween_property(panel, "position:x", 0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    return tween.finished

func fade_out():
    var tween = get_tree().create_tween()
    tween.tween_property(panel, "position:x", panel.size.x, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

    tween.finished.connect(func():
        iconloading.stop()  # detiene animación de carga
    )

    return tween.finished
