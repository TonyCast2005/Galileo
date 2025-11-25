extends Control

@onready var arduino = $Arduino # Asume que es un Control o Node2D

# --- Propiedades de Movimiento ---
@export var amplitud_y: float = 10.0      # Cuánto sube y baja (píxeles)
@export var velocidad_y: float = 0.5      # Velocidad de la flotación (frecuencia)
@export var amplitud_rotacion_deg: float = 3.0 # Inclinación máxima (grados)
@export var velocidad_rotacion: float = 0.6  # Velocidad de la inclinación

var posicion_inicial_y: float = 0.0

func _ready():
    # Guarda la posición Y original para centrar la flotación
    posicion_inicial_y = arduino.position.y

# =======================================================
# ESTA FUNCIÓN DEBE EXISTIR PARA EL MOVIMIENTO CONTINUO
# =======================================================
func _process(delta: float):
    # Obtener el tiempo para la animación continua
    var tiempo = Time.get_ticks_msec() / 1000.0
    
    # 1. Movimiento Vertical (Flotación)
    var desplazamiento_y = sin(tiempo * velocidad_y) * amplitud_y
    arduino.position.y = posicion_inicial_y + desplazamiento_y
    
    # 2. Rotación (Inclinación)
    # Convertimos los grados deseados a radianes (Godot usa radianes para rotation)
    var amplitud_rad = deg_to_rad(amplitud_rotacion_deg)
    
    # Aplicamos el seno a la rotación
    var rotacion = sin(tiempo * velocidad_rotacion) * amplitud_rad
    arduino.rotation = rotacion
