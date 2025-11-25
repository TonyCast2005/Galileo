extends Control

@onready var High = $High
@onready var Low = $Low
@onready var Exp = $Explicacion # Label o RichTextLabel para la explicación

# --- Propiedades de Flotación ---
@export var amplitud: float = 18.0   # Cuánto suben y bajan (píxeles)
@export var velocidad: float = 1 # Qué tan rápido lo hacen (frecuencia)
@export var desfase_tiempo: float = 0.3 # Retraso entre High y Low (efecto de "ola")

# Posiciones Y iniciales para centrar el movimiento
var high_pos_inicial_y: float = 0.0
var low_pos_inicial_y: float = 0.0

# --- Textos de Explicación ---
const TEXTO_HIGH = "HIGH (Encendido / 5V):\n\nRepresenta el estado de 'Encendido' o Lógico '1'. Significa que el pin está recibiendo o enviando el voltaje máximo (generalmente 5 voltios)."
const TEXTO_LOW = "LOW (Apagado / 0V):\n\nRepresenta el estado de 'Apagado' o Lógico '0'. Significa que el pin está recibiendo o enviando 0 voltios (Tierra/GND)."


func _ready():
    # 1. Guardar las posiciones Y originales
    high_pos_inicial_y = High.position.y
    low_pos_inicial_y = Low.position.y
    
    # Mensaje inicial
    Exp.text = "Haz clic en HIGH o LOW para ver su significado."


func _process(delta: float):
    # Obtener el tiempo base para la animación continua
    var tiempo = Time.get_ticks_msec() / 1000.0
    
    # 1. Movimiento para HIGH
    var desp_high = sin(tiempo * velocidad) * amplitud
    High.position.y = high_pos_inicial_y + desp_high
    
    # 2. Movimiento para LOW (con desfase)
    # Sumamos el desfase al tiempo para el efecto de "ola"
    var desp_low = sin((tiempo + desfase_tiempo) * velocidad) * amplitud
    Low.position.y = low_pos_inicial_y + desp_low


# ======================================================
# 🔹 HANDLERS DE BOTONES
# ======================================================

func _on_high_btn_pressed() -> void:
    # Muestra la explicación de HIGH
    Exp.text = TEXTO_HIGH


func _on_low_btn_pressed() -> void:
    # Muestra la explicación de LOW
    Exp.text = TEXTO_LOW
