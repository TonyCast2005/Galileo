extends Control

@onready var nombre_leccion = $nombreLeccion
@onready var instrucciones = $Instrucciones
@onready var codigo = $Panel/RichTextLabel
@onready var pista = $pista
@onready var input = $Input
@onready var validar = $validar
# Intentamos obtener la referencia de forma segura:
@onready var pc_sprite = get_node_or_null("PCSprite")  # Cambia la ruta si no es hijo directo

# Configuración de la animación
var acercando = false
var target_position = Vector2(400, 300)
var target_scale = Vector2(8, 8)
var velocidad_animacion = 2.0

var respuesta_correcta = ";"

func _ready():
	# Verificamos que pc_sprite exista antes de usarlo
	if pc_sprite == null:
		push_error("PCSprite no encontrado. Verifica que exista y que la ruta sea correcta (nombre y jerarquía).")
		# Opcional: imprimir árbol para depurar
		print_tree_pretty()
		return

	# Escala inicial y posición inicial
	pc_sprite.scale = Vector2(1, 1)
	pc_sprite.position = Vector2(200, 200)

	# Calculamos el target en el centro de la pantalla
	target_position = get_viewport().get_visible_rect().size / 2

	acercando = true

	codigo.bbcode_enabled = true
	codigo.text = """
[color=white]void[/color] main() {
	[color=lightgreen]for[/color] (int i = 0 [url=err][color=red]i < 10[/color][/url] i++) {
		print(i)
	}
}
"""

	nombre_leccion.text = "Lección: Bucles for"
	instrucciones.text = "Preparando la PC..."

func _process(delta):
	if not acercando:
		return
	# Si por alguna razón se perdió la referencia (muy raro) la chequeamos otra vez
	if pc_sprite == null:
		push_error("pc_sprite se volvió null durante la ejecución.")
		acercando = false
		return

	pc_sprite.position = pc_sprite.position.lerp(target_position, delta * velocidad_animacion)
	pc_sprite.scale = pc_sprite.scale.lerp(target_scale, delta * velocidad_animacion)

	if pc_sprite.position.distance_to(target_position) < 1.0:
		pc_sprite.position = target_position
		pc_sprite.scale = target_scale
		acercando = false
		iniciar_ejercicio()

func iniciar_ejercicio():
	instrucciones.text = "Haz clic en el error dentro del código."
	codigo.visible = true
	input.visible = false
	validar.visible = false
	pista.text = "Pista: Haz clic donde creas que está el error."
	pista.visible = true

func _on_RichTextLabel_meta_clicked(meta):
	if meta == "err":
		instrucciones.text = "¡Correcto! Ahora escribe la corrección:"
		input.visible = true
		validar.visible = true
	else:
		instrucciones.text = "Ese no es el error correcto, intenta otra vez."

func _on_validar_pressed():
	var respuesta = input.text.strip_edges()
	if respuesta == respuesta_correcta:
		instrucciones.text = "✅ ¡Bien hecho! El error se corrige con: " + respuesta_correcta
	else:
		instrucciones.text = "❌ Incorrecto. La corrección esperada era: " + respuesta_correcta
