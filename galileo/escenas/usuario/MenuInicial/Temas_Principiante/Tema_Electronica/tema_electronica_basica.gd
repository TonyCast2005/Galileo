extends Control

# ------------------------------------------------------
# 🌟 CLAVE ÚNICA PARA ESTE TEMA EN GLOBALS 🌟
# Esta clave debe ser única para el tema de Electrónica.
const THEME_KEY = "Electronica"
# ------------------------------------------------------

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

# Control de desbloqueo: cuántos botones están desbloqueados.
# Se inicializa con un valor por defecto (2), pero se sobrescribe en _ready.
var max_desbloqueado := 2

# Botón 1 → siempre lectura
var escena_lectura := "res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Electronica/Lectura/Lectura_Electronica.tscn"

# Lista de escenas de ejercicios para escoger al azar
var ejercicios_arduino := [
    {"tipo": "VF", "ruta": "res://escenas/Tipos_preguntas/VerdaderoFalso/VerdaderoFalso.tscn"},
]

func _ready():
    randomize()
    candados = [null, candado2, candado3, candado4]
    
    # ----------------------------------------------------
    # 🌟 PASO 1: CARGAR PROGRESO AL INICIAR LA ESCENA 🌟
    # ----------------------------------------------------
    if Globals.theme_progress.has(THEME_KEY):
        # Si ya existe un valor guardado para esta clave, lo usamos.
        max_desbloqueado = Globals.theme_progress[THEME_KEY]
    else:
        # Si no existe (es la primera vez), inicializamos y guardamos el valor por defecto.
        Globals.theme_progress[THEME_KEY] = max_desbloqueado

    # ----------------------------------------------------
    # PASO 2: Revisar si se terminó el examen anterior
    # ----------------------------------------------------
    if Globals.desbloquear_pendiente:
        # Si la bandera global está activa (examen aprobado), desbloqueamos.
        # Comprobamos que aún haya niveles por desbloquear.
        if max_desbloqueado < botones.size():
            # Esta función incrementa max_desbloqueado Y lo guarda en Globals.
            desbloquear_siguiente(false) # Pasamos 'false' para evitar el doble guardado
        
        # CRUCIAL: Reiniciar las banderas globales
        Globals.desbloquear_pendiente = false 
        Globals.examen_aprobado = false 

    # Finalmente, actualizar el estado visual de los botones.
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
# Llamado cuando un ejercicio termina y se aprueba
# --------------------------------------------------------
# 🌟 PASO 3: GUARDAR EL PROGRESO EN GLOBALS 🌟
func desbloquear_siguiente(guardar_en_globals: bool = true):
    if max_desbloqueado < botones.size():
        max_desbloqueado += 1
        
        # 🌟 Solo guardamos en Globals si no estamos en la fase de inicialización 
        # (cuando se llama desde _ready).
        if guardar_en_globals:
            Globals.theme_progress[THEME_KEY] = max_desbloqueado
        
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
    # Esto le indica al script del examen que debe establecer Globals.desbloquear_pendiente
    # si el examen es aprobado.
    Globals.desbloquear_pendiente = false # Lo reseteamos por si acaso
    get_tree().change_scene_to_file(ejercicio["ruta"])


# --------------------------------------------------------
# Botones (Se elimina la llamada directa a desbloquear_siguiente())
# --------------------------------------------------------
func _on_button_1_pressed():
    get_tree().change_scene_to_file(escena_lectura)


func _on_button_2_pressed() -> void:
    cargar_escena_ejercicio(ejercicio_aleatorio())
    # NOTA: Se eliminan las llamadas directas aquí. El desbloqueo ocurre 
    # automáticamente en _ready cuando el examen regresa con éxito.

func _on_button_3_pressed() -> void:
    cargar_escena_ejercicio(ejercicio_aleatorio())

func _on_button_4_pressed() -> void:
    cargar_escena_ejercicio(ejercicio_aleatorio())
    
    
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
