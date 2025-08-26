extends Panel

@onready var tween = get_tree().create_tween()
@onready var label = $Label
@onready var toggle_button = $ToggleButton  # botón dentro del panel

var panel_open = false

func _ready():
    # Conectamos el botón a la función toggle
    toggle_button.pressed.connect(toggle_panel)

func toggle_panel():
    tween.kill()  # cancela cualquier animación anterior
    if panel_open:
        # Cerrar: subir fuera de la pantalla
        tween.tween_property(self, "rect_position:y", -size.y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        panel_open = false
    else:
        # Abrir: bajar a posición visible
        tween.tween_property(self, "rect_position:y", 0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        panel_open = true
