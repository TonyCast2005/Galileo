extends Control

@onready var Voltaje = $Voltaje
@onready var Corriente = $Corriente
@onready var Resistencia = $Resistencia
@onready var Explicacion = $Panel2/Explicacion

# --- Propiedades de Flotación ---
@export var amplitud: float = 12.0     # Cuánto suben y bajan (píxeles)
@export var velocidad: float = 0.9     # Qué tan rápido lo hacen (frecuencia)
@export var desfase_tiempo: float = 0.2 # Retraso entre cada elemento (efecto "escalera")

# Posiciones Y iniciales para centrar el movimiento
var voltaje_pos_inicial_y: float = 0.0
var corriente_pos_inicial_y: float = 0.0
var resistencia_pos_inicial_y: float = 0.0

# --- Textos de Explicación ---
const TEXTO_VOLTAJE = " Voltaje (Voltios - V): Es la presión o la fuerza que empuja a los electrones a moverse. En Arduino, usualmente es de 5V."
const TEXTO_CORRIENTE = " Corriente (Amperios - A): Es el flujo real y la cantidad de electrones que pasan por un punto en un segundo. Es lo que hace el trabajo."
const TEXTO_RESISTENCIA = " Resistencia (Ohmios - Ω): Es la oposición o fricción al paso de la Corriente. Se usa para limitar el flujo y proteger los componentes."


func _ready():
    # 1. Guardar las posiciones Y originales
    voltaje_pos_inicial_y = Voltaje.position.y
    corriente_pos_inicial_y = Corriente.position.y
    resistencia_pos_inicial_y = Resistencia.position.y
    
    Explicacion.text = "Haz clic en cada concepto para ver su definición."


func _process(delta: float):
    # Obtener el tiempo base para la animación continua
    var tiempo = Time.get_ticks_msec() / 1000.0
    
    # 1. Movimiento para VOLTAJE (El líder de la ola)
    var desp_v = sin(tiempo * velocidad) * amplitud
    Voltaje.position.y = voltaje_pos_inicial_y + desp_v
    
    # 2. Movimiento para CORRIENTE (Desfase simple)
    # Empieza la ola 0.2s después de Voltaje
    var desp_c = sin((tiempo + desfase_tiempo) * velocidad) * amplitud
    Corriente.position.y = corriente_pos_inicial_y + desp_c
    
    # 3. Movimiento para RESISTENCIA (Doble desfase)
    # Empieza la ola 0.4s después de Voltaje, cerrando la fila
    var desp_r = sin((tiempo + (desfase_tiempo * 2)) * velocidad) * amplitud
    Resistencia.position.y = resistencia_pos_inicial_y + desp_r


# ======================================================
# 🔹 HANDLERS DE BOTONES
# ======================================================

func _on_voltaje_pressed() -> void:
    Explicacion.text = TEXTO_VOLTAJE

func _on_corriente_pressed() -> void:
    Explicacion.text = TEXTO_CORRIENTE

func _on_resistencia_pressed() -> void:
    Explicacion.text = TEXTO_RESISTENCIA
