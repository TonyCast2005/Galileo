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
# 1 es la lectura. 2, 3, 4 son ejercicios.
# Si el botón 1 (índice 0) está desbloqueado, max_desbloqueado debe ser 1 (1 + 0 = 1).
# Si el botón 3 (índice 2) está desbloqueado, max_desbloqueado debe ser 3 (3 + 0 = 3).
# Si 3 está desbloqueado, es probable que se refiera al botón 4 (índice 3).
# Dejamos 3, que implica que los botones 1, 2 y 3 están activos al inicio (índices 0, 1, 2).
var max_desbloqueado := 2

# Botón 1 → siempre lectura
var escena_lectura := "res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/Ejercicios/Lectura/Lectura_Arduino.tscn"

# Lista de escenas de ejercicios para escoger al azar
var ejercicios_arduino := [
    {"tipo": "OM1", "ruta": "res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/Ejercicios/OpcMultiple_1.tscn"},
    {"tipo": "VF", "ruta": "res://escenas/Tipos_preguntas/VerdaderoFalso/VerdaderoFalso.tscn"},
    {"tipo": "PA", "ruta": "res://escenas/Tipos_preguntas/PreguntasAbiertas/PreguntasAbiertas.tscn"},
    {"tipo": "SA", "ruta": "res://escenas/Tipos_preguntas/SemiAbiertas/SemiAbiertas.tscn"},
    {"tipo": "PE", "ruta": "res://escenas/Tipos_preguntas/practicaEscritura/practicaEscritura.tscn"},
]

func _ready():
    randomize()
    candados = [null, candado2, candado3, candado4]
    
    # ----------------------------------------------------
    # 🌟 NUEVA LÓGICA DE DESBLOQUEO AL CARGAR LA ESCENA 🌟
    # ----------------------------------------------------
    if Globals.desbloquear_pendiente:
        # Si la bandera global está activa (porque el examen terminó exitosamente):
        desbloquear_siguiente() # Desbloquea el siguiente candado
        # CRUCIAL: Reiniciar la bandera global para que no desbloquee en el siguiente regreso.
        Globals.desbloquear_pendiente = false 
        Globals.examen_aprobado = false # Resetear también el estado de aprobación
        
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
        # El botón está activo si su índice es menor al máximo desbloqueado
        if i < max_desbloqueado: 
            botones[i].disabled = false
            if candados[i]:
                candados[i].visible = false
        else:
            # Si no está desbloqueado, se deshabilita y se muestra el candado
            botones[i].disabled = true
            if candados[i]:
                candados[i].visible = true


# --------------------------------------------------------
# Llamado cuando un ejercicio termina (solo si lo apruebas)
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
    # La bandera Globals.desbloquear_pendiente se pone a true
    # en el script del examen, *antes* de regresar a esta escena,
    # *solo si* el examen fue aprobado.
    get_tree().change_scene_to_file(ejercicio["ruta"])


# --------------------------------------------------------
# Botones (Se elimina la llamada directa a desbloquear_siguiente())
# --------------------------------------------------------
func _on_button_1_pressed():
    get_tree().change_scene_to_file(escena_lectura)


func _on_button_2_pressed() -> void:
    cargar_escena_ejercicio(ejercicio_aleatorio())
    # ❌ ELIMINADO: desbloquear_siguiente()

func _on_button_3_pressed() -> void:
    cargar_escena_ejercicio(ejercicio_aleatorio())
    # ❌ ELIMINADO: desbloquear_siguiente()

func _on_button_4_pressed() -> void:
    cargar_escena_ejercicio(ejercicio_aleatorio())
    # ❌ ELIMINADO: desbloquear_siguiente()
    
    
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
