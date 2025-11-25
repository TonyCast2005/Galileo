extends Control

@onready var contenedor: Control = $Carrusel

var temas: Array = [
	preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/Ejercicios/Lectura/pagina1.tscn"),
	preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/Ejercicios/Lectura/pagina2.tscn"),
	preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/Ejercicios/Lectura/pagina3.tscn"),
]

var indice_actual := 0
var escena_actual: Control = null
var animando := false

func _ready():
	cargar_tema(indice_actual, 0)

# ============================================================
#   CARGAR TEMA CON ANIMACIÓN TIPO "CARRUSEL"
# ============================================================
func cargar_tema(i: int, direccion: int):
	if animando:
		return
	animando = true

	var nueva_escena := temas[i].instantiate() as Control
	contenedor.add_child(nueva_escena)

	# Anclas
	nueva_escena.anchor_left = 0
	nueva_escena.anchor_right = 1
	nueva_escena.anchor_top = 0
	nueva_escena.anchor_bottom = 1
	nueva_escena.position = Vector2.ZERO

	var ancho := contenedor.size.x

	# Primera carga → sin animación
	if escena_actual == null:
		escena_actual = nueva_escena
		animando = false
		return

	# Nueva escena entra desde derecha o izquierda
	nueva_escena.position = Vector2(direccion * ancho, 0)

	var tween := create_tween()

	# Sale la escena actual
	tween.tween_property(escena_actual, "position:x", -direccion * ancho, 0.10)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Entra la nueva
	tween.tween_property(nueva_escena, "position:x", 0, 0.20)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		if escena_actual:
			escena_actual.queue_free()
		escena_actual = nueva_escena
		animando = false
	)

# ============================================================
#   BOTONES
# ============================================================
func _on_atras_pressed() -> void:
	if animando: return
	if indice_actual > 0:
		indice_actual -= 1
		cargar_tema(indice_actual, -1)

func _on_adelante_pressed() -> void:
	if animando: return

	if indice_actual < temas.size() - 1:
		indice_actual += 1
		cargar_tema(indice_actual, 1)
	else:
		Globals.desbloquear = true
		Globals.repetir_bloque = false
		get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")
