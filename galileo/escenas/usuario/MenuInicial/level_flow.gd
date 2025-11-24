extends Control

var steps = []       # ← aquí se guardan las escenas del nivel
var index = 0        # paso actual

func _ready():
    load_level_data()
    load_step()


func load_level_data():
    var nivel = Globals.nivel_actual
    steps = Globals.niveles[nivel]

func load_step():
    # limpiar step previo
    for c in get_children():
        c.queue_free()

    var scene = load(steps[index]).instantiate()
    add_child(scene)

    # conectar la señal "continuar"
    if scene.has_signal("continuar"):
       scene.connect("continuar", _on_step_completed)
