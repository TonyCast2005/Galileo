extends Control

@onready var achievements_list = $Scrolllogros/logroslist
var logro_scene = preload("res://scenes/ui/logrocontenedor/logrocontainer.tscn")

func _ready():
    load_test_logros()

func load_test_logros():
    # Datos de prueba
    var test_data = {
        "logro1": {
            "icono": "res://assets/sprites/trophies/Pez gordo .png",
            "nombre": "Primer Paso",
            "descripcion": "Completaste tu primera lección."
        },
        "logro2": {
            "icono": "res://assets/sprites/trophies/Pez gordo .png",
            "nombre": "Aprendiz",
            "descripcion": "Has desbloqueado 5 logros."
        },
        "logro3": {
            "icono": "res://assets/sprites/trophies/Pez gordo .png",
            "nombre": "Veterano",
            "descripcion": "Terminaste 10 lecciones."
        }
    }

    # Crear logros en la lista
    for key in test_data.keys():
        var info = test_data[key]
        var logro = logro_scene.instantiate()
        var tex = load(info["icono"])
        logro.set_data(tex, info["nombre"], info["descripcion"])
        achievements_list.add_child(logro)
