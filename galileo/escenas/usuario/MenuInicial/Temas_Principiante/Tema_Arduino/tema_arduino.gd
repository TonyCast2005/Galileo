extends Control

# --- Candados ---
@onready var candado2 = $Panel/HBoxContainer2/Panel2/Button2/candado2
@onready var candado3 = $Panel/HBoxContainer3/Panel3/Button3/candado3
@onready var candado4 = $Panel/HBoxContainer4/Panel4/Button4/candado4


#-.Cajas

@onready var caja1 = $Panel/HBoxContainer1
@onready var caja2 = $Panel/HBoxContainer2
@onready var caja3 = $Panel/HBoxContainer3
@onready var caja4 = $Panel/HBoxContainer4




# --- Botones ---
@onready var botones = [
	$Panel/HBoxContainer1/Panel1/Button1,
	$Panel/HBoxContainer2/Panel2/Button2,
	$Panel/HBoxContainer3/Panel3/Button3,
	$Panel/HBoxContainer4/Panel4/Button4
]

# Lista de candados para sincronizar
var candados := []

# Control de desbloqueo: cuántos botones están desbloqueados
var max_desbloqueado := 4

# Botón 1 → siempre lectura
var escena_lectura := "res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/Ejercicios/Lectura/Lectura_Arduino.tscn"

# Lista de escenas de ejercicios para escoger al azar
var ejercicios_arduino := [
	{"tipo": "OM1", "ruta": "res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/Ejercicios/OpcMultiple_1.tscn"},
	{"tipo": "VF", "ruta": "res://escenas/Tipos_preguntas/VerdaderoFalso/VerdaderoFalso.tscn"},
	{"tipo": "OM2", "ruta": "res://escenas/Tipos_preguntas/PreguntasAbiertas/PreguntasAbiertas.tscn"},
	{"tipo": "CE", "ruta": "res://escenas/Tipos_preguntas/CodigoConErrores/CodigoConErrores.tscn"},
	{"tipo": "PE", "ruta": "res://escenas/Tipos_preguntas/practicaEscritura/practicaEscritura.tscn"},
]

func _ready():
	randomize()
	candados = [null, candado2, candado3, candado4]
	_actualizar_estado_botones()

	# ---- Animación flotante ----
	_animar_caja_flotante(caja1, 0.0)
	_animar_caja_flotante(caja2, 0.3)
	_animar_caja_flotante(caja3, 0.6)
	_animar_caja_flotante(caja4, 0.9)



# --------------------------------------------------------
# Actualiza los candados y botones según progreso
# --------------------------------------------------------
func _actualizar_estado_botones():
	for i in range(botones.size()):
		if i < max_desbloqueado:
			botones[i].disabled = false
			if candados[i]:
				candados[i].visible = false
		else:
			botones[i].disabled = true
			if candados[i]:
				candados[i].visible = true


# --------------------------------------------------------
# Llamado cuando un ejercicio termina
# (lo llamas desde el botón "Continuar" dentro del ejercicio)
# --------------------------------------------------------
func desbloquear_siguiente():
	if max_desbloqueado < botones.size():
		max_desbloqueado += 1
		_actualizar_estado_botones()


# --------------------------------------------------------
# Devuelve un ejercicio aleatorio
# --------------------------------------------------------
func ejercicio_aleatorio() -> Dictionary:
	var index = randi() % ejercicios_arduino.size()
	return ejercicios_arduino[index]


# --------------------------------------------------------
# Cargar escena completa de ejercicio (cambia de pantalla)
# --------------------------------------------------------
func cargar_escena_ejercicio(ejercicio: Dictionary):
	Globals.desbloquear_pendiente = true
	get_tree().change_scene_to_file(ejercicio["ruta"])



# --------------------------------------------------------
# Botones
# --------------------------------------------------------
func _on_button_1_pressed():
   
	get_tree().change_scene_to_file(escena_lectura)


func _on_button_2_pressed() -> void:
	cargar_escena_ejercicio(ejercicio_aleatorio())
	desbloquear_siguiente()

func _on_button_3_pressed() -> void:
	cargar_escena_ejercicio(ejercicio_aleatorio())
	desbloquear_siguiente()

func _on_button_4_pressed() -> void:
	cargar_escena_ejercicio(ejercicio_aleatorio())
	desbloquear_siguiente()
	
	
func _animar_caja_flotante(nodo: Control, delay: float):
	var tween = get_tree().create_tween()
	tween.set_loops() # Animación infinita
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	var up = nodo.position + Vector2(0, -10)
	var down = nodo.position + Vector2(0, 10)

	# Esperamos el tiempo de delay
	tween.tween_interval(delay)

	# Secuencia de movimiento
	tween.tween_property(nodo, "position", up, 2.0)
	tween.tween_property(nodo, "position", down, 2.0)
	tween.tween_property(nodo, "position", nodo.position, 2.0)
