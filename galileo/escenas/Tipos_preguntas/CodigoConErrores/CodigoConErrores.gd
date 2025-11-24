extends Control

@onready var nombre_leccion = $nombreLeccion
@onready var instrucciones = $Instrucciones
@onready var codigo = $Panel/RichTextLabel
@onready var pista = $pista
@onready var input = $Input
@onready var validar = $validar
@onready var pc_sprite = $PCSprite  # Asegúrate de tener el nodo de la PC

# Configuración de la animación
var acercando = false
var target_position = Vector2(400, 300)  # Ajusta según el centro de tu pantalla
var target_scale = Vector2(8, 8)         # Escala final del sprite
var velocidad_animacion = 2.0            # Qué tan rápido se acerca

# Respuesta correcta
var respuesta_correcta = ";"

func _ready():
	# Escala inicial
	pc_sprite.scale = Vector2(1, 1)
	
	# Posición inicial (opcional)
	pc_sprite.position = Vector2(200, 200)  # Donde empieza antes de acercarse

	# Calculamos el target en el centro de la pantalla
	target_position = get_viewport().get_visible_rect().size / 2

	# Activamos la animación
	acercando = true

	# Texto de ejemplo con error
	codigo.bbcode_enabled = true
	codigo.text = """
[color=white]void[/color] main() {
	[color=lightgreen]for[/color] (int i = 0 [url=err][color=red]i < 10[/color][/url] i++) {
		print(i)
	}
}
"""

	# Nombre de la lección
	nombre_leccion.text = "Lección: Bucles for"
	instrucciones.text = "Preparando la PC..."

	# Iniciamos la animación de acercamiento
	acercando = true

func _process(delta):
	if acercando:
		# Interpolamos posición y escala usando lerp (Godot 4)
		pc_sprite.position = pc_sprite.position.lerp(target_position, delta * velocidad_animacion)
		pc_sprite.scale = pc_sprite.scale.lerp(target_scale, delta * velocidad_animacion)

		# Verificamos si llegó al target
		if pc_sprite.position.distance_to(target_position) < 1.0:
			pc_sprite.position = target_position
			pc_sprite.scale = target_scale
			acercando = false
			iniciar_ejercicio()


# Función que activa el código y los botones después de la animación
func iniciar_ejercicio():
	instrucciones.text = "Haz clic en el error dentro del código."
	codigo.visible = true
	input.visible = false
	validar.visible = false
	pista.text = "Pista: Haz clic donde creas que está el error."
	pista.visible = true

# Cuando el jugador hace clic en un fragmento del código
func _on_RichTextLabel_meta_clicked(meta):
	if meta == "err":
		instrucciones.text = "¡Correcto! Ahora escribe la corrección:"
		input.visible = true
		validar.visible = true
	else:
		instrucciones.text = "Ese no es el error correcto, intenta otra vez."

# Cuando presiona el botón de validar
func _on_validar_pressed():
	var respuesta = input.text.strip_edges()
	if respuesta == respuesta_correcta:
		instrucciones.text = "✅ ¡Bien hecho! El error se corrige con: " + respuesta_correcta
	else:
		instrucciones.text = "❌ Incorrecto. La corrección esperada era: " + respuesta_correcta
