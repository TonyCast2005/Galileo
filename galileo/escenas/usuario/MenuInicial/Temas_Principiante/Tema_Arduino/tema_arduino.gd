extends Control

# --- Candados ---
@onready var candado2 = $Panel/VBoxContainer/Button2/TextureRect2
@onready var candado3 = $Panel/VBoxContainer/Button3/TextureRect3
@onready var candado4 = $Panel/VBoxContainer/Button4/TextureRect4

# --- Botones ---
@onready var botones = [
	$Panel/VBoxContainer/Button1,
	$Panel/VBoxContainer/Button2,
	$Panel/VBoxContainer/Button3,
	$Panel/VBoxContainer/Button4
]

# Lista de candados para sincronizar
var candados := []

# Control de desbloqueo: cuántos botones están desbloqueados
var max_desbloqueado := 4

# Botón 1 → siempre lectura
var escena_lectura := "res://escenas/Tipos_preguntas/Lectura/Lectura.tscn"

# Lista de escenas de ejercicios para escoger al azar
var ejercicios_arduino := [
	{"tipo": "OM1", "ruta": "res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/OpcMultiple_1.tscn"},
   	{"tipo": "VF", "ruta": "res://escenas/Tipos_preguntas/VerdaderoFalso/VerdaderoFalso.tscn"},
	{"tipo": "OM2", "ruta": "res://escenas/Tipos_preguntas/PreguntasAbiertas/PreguntasAbiertas.tscn"},
	{"tipo": "SA", "ruta": "res://escenas/Tipos_preguntas/SemiAbiertas/SemiAbiertas.tscn"},
	{"tipo": "PE", "ruta": "res://escenas/Tipos_preguntas/practicaEscritura/practica_escritura.gd"},
	
]

func _ready():
	randomize()

	# Guardamos los candados alineados con los botones
	candados = [null, candado2, candado3, candado4]

	_actualizar_estado_botones()

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
