extends Control

@onready var achievements_list = $ScrollContainer/Control  # mejor que Control sea un VBoxContainer
var LogroScene = preload("res://escenas/usuario/Perfil/Logro.tscn")  # cambia a la ruta de tu escena de logro

func add_achievement(icon: Texture, title: String, description: String):
	var logro = LogroScene.instantiate()
	logro.set_data(icon, title, description)
	achievements_list.add_child(logro)

func _ready():
	var icon = preload("res://assets/sprites/ui/Logros/de noche todos los gatos son pardos.png")  # cámbialo a tu icono
	add_achievement(icon, "Primer paso", "Completaste el tutorial con éxito")
	add_achievement(icon, "Explorador", "Visitaste todas las secciones del perfil")
