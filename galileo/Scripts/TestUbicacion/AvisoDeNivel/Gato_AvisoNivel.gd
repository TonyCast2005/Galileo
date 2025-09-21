extends Sprite2D

func _ready():
    inclinar()

func inclinar():
    var tween = create_tween()
    tween.set_loops() # se repite infinito

    # Inclinar a la derecha (0.2 rad ≈ 11 grados)
    tween.tween_property(self, "rotation", 0.2, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    # Inclinar a la izquierda (-0.2 rad)
    tween.tween_property(self, "rotation", -0.2, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    # Regresar al centro (0 rad)
    tween.tween_property(self, "rotation", 0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
