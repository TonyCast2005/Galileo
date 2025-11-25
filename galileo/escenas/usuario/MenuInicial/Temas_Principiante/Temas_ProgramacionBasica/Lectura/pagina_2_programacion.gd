extends Control

@onready var tipo = $tipo
@onready var nombre = $Nombre
@onready var valor = $valor

# --- Propiedades de Flotación ---
@export var amplitud: float = 13.0  # Cuánto suben y bajan (píxeles)
@export var velocidad: float = 0.9  # Qué tan rápido lo hacen (frecuencia)

# Propiedad para controlar el retraso entre cada nodo (¡Clave!)
@export var desfase_tiempo: float = 0.2 

# Guardarán las posiciones Y originales para centrar el movimiento
var pos_inicial_y: float = 0.0

func _ready():
    # Eliminamos la rotación
    
    # 1. Guardar la posición Y inicial (usamos la de 'nombre' como referencia central)
    pos_inicial_y = nombre.position.y
    # Asumimos que los tres nodos están alineados verticalmente aquí
    
func _process(delta: float):
    # Obtener el tiempo base para la animación continua
    var tiempo = Time.get_ticks_msec() / 1000.0
    
    # 1. Calcular el desplazamiento para 'tipo' (El líder)
    var desp_tipo = sin(tiempo * velocidad) * amplitud
    tipo.position.y = pos_inicial_y + desp_tipo
    
    # 2. Calcular el desplazamiento para 'nombre' (Desfase simple)
    # Sumamos el desfase al tiempo para que empiece la ola después
    var desp_nombre = sin((tiempo + desfase_tiempo) * velocidad) * amplitud
    nombre.position.y = pos_inicial_y + desp_nombre
    
    # 3. Calcular el desplazamiento para 'valor' (Doble desfase)
    # Sumamos el doble del desfase para que vaya de último en la ola
    var desp_valor = sin((tiempo + (desfase_tiempo * 2)) * velocidad) * amplitud
    valor.position.y = pos_inicial_y + desp_valor
