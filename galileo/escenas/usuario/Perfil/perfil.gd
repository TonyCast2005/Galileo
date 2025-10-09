extends Control

@onready var achievements_list = $ScrollContainer/logrosVbox

var LogroScene = preload("res://escenas/usuario/Perfil/Logro.tscn")
# Array de logros de prueba
var logros_prueba = [
	{"nombre":"Primer paso", "descripcion":"Completaste el tutorial con éxito", "icono":"res://assets/sprites/ui/Logros/catbox.png"},
	{"nombre":"Aprendiz veloz", "descripcion":"Completar un nivel en la mitad de tiempo promedio", "icono":"res://assets/sprites/ui/Logros/aprendizVeloz.png"},
	{"nombre":"Aprendiz visual", "descripcion":"Completa 10 ejercicios basados en ABE", "icono":"res://assets/sprites/ui/Logros/aprendizVisual.png"},
	{"nombre":"Caja de cartón", "descripcion":"Completa todas las lecciones de un nivel", "icono":"res://assets/sprites/ui/Logros/caja_de_cartón.png"},
	{"nombre":"Cazador de Bugs", "descripcion":"Corrige 10 errores de código", "icono":"res://assets/sprites/ui/Logros/cazadorDeBugs.png"},
	{"nombre":"Pez gordo", "descripcion":"Aprueba un examen de nivel Intermedio", "icono":"res://assets/sprites/ui/Logros/Pez_gordo.png"},
	{"nombre":"Gato PWM", "descripcion":"Completa una lección 10 días seguidos", "icono":"res://assets/sprites/ui/Logros/PWM.png"},
	{"nombre":"El minino resiste", "descripcion":"Completa una lección 5 días seguidos", "icono":"res://assets/sprites/ui/Logros/el_minino_resiste.png"},
	{"nombre":"Leyenda del cable", "descripcion":"Completa una lección difícil", "icono":"res://assets/sprites/ui/Logros/Leyenda_del_cable_masticado.png"},
	{"nombre":"Gato velocista", "descripcion":"Contesta 5 preguntas en menos del 50% del tiempo", "icono":"res://assets/sprites/ui/Logros/gatoVelocista.png"},
	{"nombre":"Explorador inalcanzable", "descripcion":"Resolver 15 ejercicios de descubrimiento guiado", "icono":"res://assets/sprites/ui/Logros/ExploradorInalcanzable.png"},
	{"nombre":"Primera presa", "descripcion":"Completa tu primera lección", "icono":"res://assets/sprites/ui/Logros/primeraPresa.png"},
	{"nombre":"Experto en arduino", "descripcion":"Completa el último nivel de experimentado", "icono":"res://assets/sprites/ui/Logros/expertoEnArduino.png"},
	{"nombre":"Teórico nato", "descripcion":"Acertar 20 preguntas con la metodología aprendizaje significativo", "icono":"res://assets/sprites/ui/Logros/teoricoNato.png"},
	{"nombre":"Cazador de bugs", "descripcion":"Corregir 10 errores de código", "icono":"res://assets/sprites/ui/Logros/cazadorDeBugs.png"},
	{"nombre":"Pelea en el techo", "descripcion":"Responder 10 preguntas seguidas correctamente", "icono":"res://assets/sprites/ui/Logros/Pelea_en_el techo.png"}
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

	
