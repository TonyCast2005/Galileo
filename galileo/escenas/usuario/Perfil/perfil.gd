extends Control

@onready var achievements_list = $ScrollContainer/logrosVbox

var LogroScene = preload("res://escenas/usuario/Perfil/Logro.tscn")

# Array de logros de prueba
var logros_prueba = [
    {"nombre":"Primer paso", "descripcion":"Completaste el tutorial con éxito", "icono":"res://assets/sprites/ui/Logros/de_noche_todos_los_gatos_son_pardos.png"},
    {"nombre":"Explorador", "descripcion":"Visitaste todas las secciones del perfil", "icono":"res://assets/sprites/ui/Logros/aprendiz_veloz.png"},
    {"nombre":"Aprendiz visual", "descripcion":"Completa 10 ejercicios basados en ABE", "icono":"res://assets/sprites/ui/Logros/aprendiz_visual.png"},
    {"nombre":"Caja de cartón", "descripcion":"Completa todas las lecciones de un nivel", "icono":"res://assets/sprites/ui/Logros/caja_carton.png"},
    {"nombre":"Cazador de Bugs", "descripcion":"Corrige 10 errores de código", "icono":"res://assets/sprites/ui/Logros/cazador_bugs.png"},
    {"nombre":"Pez gordo", "descripcion":"Aprueba un examen de nivel Intermedio", "icono":"res://assets/sprites/ui/Logros/pez_gordo.png"},
    {"nombre":"Gato PWM", "descripcion":"Completa una lección 10 días seguidos", "icono":"res://assets/sprites/ui/Logros/gato_pwm.png"},
    {"nombre":"El minino resiste", "descripcion":"Completa una lección 5 días seguidos", "icono":"res://assets/sprites/ui/Logros/el_minino_resiste.png"},
    {"nombre":"Leyenda del cable", "descripcion":"Completa una lección difícil", "icono":"res://assets/sprites/ui/Logros/leyenda_cable.png"},
    {"nombre":"Gato velocista", "descripcion":"Contesta 5 preguntas en menos del 50% del tiempo", "icono":"res://assets/sprites/ui/Logros/gato_velocista.png"}
]

func _ready():
    mostrar_logros()

func mostrar_logros():
    # Limpiar lista
    for child in achievements_list.get_children():
        child.queue_free()

    # Recorrer los logros de prueba
    for logro_data in logros_prueba:
        var icon = load(logro_data["icono"])
        print("Cargando logro:", logro_data["nombre"], "icon:", icon)
        add_achievement(icon, logro_data["nombre"], logro_data["descripcion"], true)

func add_achievement(icon: Texture, title: String, description: String, unlocked: bool):
    var logro = LogroScene.instantiate()
    achievements_list.add_child(logro)
    logro.call_deferred("set_data", icon, title, description, unlocked)
