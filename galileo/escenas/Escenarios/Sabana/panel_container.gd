extends PanelContainer

@export var boton: Button
@export var margen_superior := 0
var desplegado := false

func _ready():
    var viewport = get_viewport_rect()

    # Panel
    set_anchors_preset(Control.PRESET_TOP_LEFT)
    anchor_bottom = 0
    anchor_right = 0
    position.y = viewport.size.y
    size.y = viewport.size.y - margen_superior

    # Fondo semitransparente
    var estilo = StyleBoxFlat.new()
    estilo.bg_color = Color(0.1, 0.1, 0.1, 0.9)  # gris oscuro con opacidad
    add_theme_stylebox_override("panel", estilo)

    # Botón
    if boton:
        boton.reparent(get_tree().root)
        boton.set_anchors_preset(Control.PRESET_TOP_LEFT)
        boton.anchor_bottom = 0
        boton.anchor_right = 0
        boton.position.x = (viewport.size.x - boton.size.x) / 2
        boton.position.y = viewport.size.y - boton.size.y

func toggle_panel():
    desplegado = !desplegado
    var viewport = get_viewport_rect()
    var destino_y = margen_superior if desplegado else viewport.size.y
    var tween = create_tween().set_parallel(true)
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "position:y", destino_y, 0.5)
