extends Control

@onready var pyc = $panelpunto/puntoycoma # Asumimos que es un Node2D o Control

# --- Propiedades de Animación ---
# Movimiento General
@export var amplitud_xy: float = 8.0     # Cuánto se moverá en X e Y (radio)
@export var velocidad_flotacion: float = 1.0 # Velocidad media de la onda (más rápido que la nube)

# Rotación (Inclinación)
@export var max_inclinacion_deg: float = 15.0 # Ángulo máximo de inclinación (en grados)
@export var velocidad_rotacion: float = 1.5   # Velocidad de la inclinación (un poco más rápida)

# Posición inicial para centrar el movimiento
var pos_inicial: Vector2 = Vector2.ZERO

func _ready():
    # 1. Guardar la posición inicial del punto y coma
    pos_inicial = pyc.position
    
    # 2. Centrar su pivote de rotación
    # Esto es crucial para que rote sobre su propio centro y no sobre la esquina superior izquierda.
    if pyc is Control:
        pyc.pivot_offset = pyc.size / 2.0
    # Si es Sprite2D, asegúrate de que el Offset (origen) esté en el centro (0.5, 0.5)

func _process(delta: float):
    # Obtener el tiempo base para la animación continua
    var tiempo = Time.get_ticks_msec() / 1000.0
    
    # ==================================
    # 1. Movimiento de Flotación (Círculo/Elipse)
    # ==================================
    
    # Usamos sin() para Y y cos() para X para que se muevan en un patrón circular/elíptico.
    var desplazamiento_x = cos(tiempo * velocidad_flotacion) * amplitud_xy
    var desplazamiento_y = sin(tiempo * velocidad_flotacion) * amplitud_xy
    
    pyc.position.x = pos_inicial.x + desplazamiento_x
    pyc.position.y = pos_inicial.y + desplazamiento_y
    
    # ==================================
    # 2. Rotación/Inclinación
    # ==================================
    
    # Usamos una velocidad diferente para la rotación para que no sea predecible
    var rotacion_rad = deg_to_rad(max_inclinacion_deg)
    
    # Multiplicamos el tiempo por velocidad_rotacion para el efecto de inclinación
    var inclinacion = sin(tiempo * velocidad_rotacion) * rotacion_rad
    
    pyc.rotation = inclinacion
