extends Panel

@onready var toggle_button = $ToggleButton
@onready var blocks_container = $VBoxContainer

var panel_open = false

func _ready():
    # Inicializamos posición fuera de pantalla
    position.y = -size.y  
    toggle_button.pressed.connect(_on_toggle_button_pressed)

func _on_toggle_button_pressed():
    var tween = get_tree().create_tween()
    
    if panel_open:
            tween.tween_property(self, "position:y", -size.y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
            panel_open = false
    else:
        tween.tween_property(self, "position:y", 0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        panel_open = true
