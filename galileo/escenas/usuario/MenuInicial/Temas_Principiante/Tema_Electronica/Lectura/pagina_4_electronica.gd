extends Control

@onready var Resistor = $Resistor # Asegúrate de que $Resistor es un Node2D o Control

# --- Propiedades de Rotación ---
@export var max_inclinacion_deg: float = 10.0 # Ángulo máximo de inclinación (en grados)
@export var velocidad_rotacion: float = 0.99   # Velocidad de la inclinación (frecuencia)

# Posición inicial para la rotación (no la necesitamos directamente para la rotación,
# pero es bueno tenerla si se quisiera mover también)
var rotacion_inicial: float = 0.0

func _ready():
    # 1. Guardar la rotación inicial del resistor (asumimos 0 si no lo has rotado)
    rotacion_inicial = Resistor.rotation
    
    # 2. Centrar el pivote de rotación del resistor
    # Esto es crucial para que rote sobre su propio centro y no sobre una esquina.
    if Resistor is Control:
        Resistor.pivot_offset = Resistor.size / 2.0
    elif Resistor is Sprite2D: # Si es un Sprite2D
        # Asegúrate de que el Offset (origen) del Sprite2D esté en el centro (0.5, 0.5)
        # Esto se suele hacer en el editor, pero puedes forzarlo si es necesario.
        pass # No es directamente modificable por script sin el editor para el offset

func _process(delta: float):
    # Obtener el tiempo base para la animación continua
    var tiempo = Time.get_ticks_msec() / 1000.0
    
    # ==================================
    # Rotación/Inclinación
    # ==================================
    
    # Convertimos los grados deseados a radianes (Godot usa radianes para rotation)
    var rotacion_rad = deg_to_rad(max_inclinacion_deg)
    
    # Aplicamos la función seno para una inclinación suave de lado a lado
    var inclinacion = sin(tiempo * velocidad_rotacion) * rotacion_rad
    
    # Sumamos la rotación inicial para que la inclinación sea alrededor de su valor original
    Resistor.rotation = rotacion_inicial + inclinacion
