extends Control

#-.Cajas
@onready var Estrella = $Estrella as AnimatedSprite2D # Definimos el tipo para mayor claridad
@onready var bloqueado = $bloqueado
# --- Botones (Solo el botón dentro de la Estrella) ---
@onready var boton_examen = $Estrella/Empezar_Examen

# Rutas de Escena
var escena_destino := "res://escenas/usuario/MenuInicial/Temas_Principiante/Examen_Principiante/Examen_Escena/ExamenNovato.tscn"

# Posición inicial para la animación
var pos_inicial_estrella: Vector2

func _ready():
    # 1. Guardar la posición inicial de la Estrella
    # Usamos el nodo Estrella (AnimatedSprite2D), que hereda de Node2D
    pos_inicial_estrella = Estrella.position
    
    # 🌟 ¡NUEVO! 🌟
    # Asegúrate de que el AnimatedSprite2D comience a reproducir su animación.
    # Si tienes varias animaciones, reemplaza "default" con el nombre de tu animación.
    Estrella.play("default")
    
    # 2. Iniciar la animación flotante
    _animar_caja_flotante(Estrella, 0.0)

    if Globals.desbloquear5:
        bloqueado.hide()
# ============================================================
#    ANIMACIÓN FLOTANTE (Ahora acepta Node2D)
# ============================================================
func _animar_caja_flotante(nodo: Node2D, delay: float):
    var tween = get_tree().create_tween()

    tween.set_loops() # INFINITO
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)

    var up = nodo.position + Vector2(0, -13)
    var down = nodo.position + Vector2(0, 10)

    tween.tween_interval(delay)

    tween.tween_property(nodo, "position", up, 2.5)
    tween.tween_property(nodo, "position", down, 2.5)



# ============================================================
#    MANEJO DEL BOTÓN
# ============================================================

func _on_empezar_examen_pressed() -> void:
    get_tree().change_scene_to_file(escena_destino)
