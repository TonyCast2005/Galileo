extends Control

@onready var Loop = $Loop
@onready var Setup = $Setup
@onready var explicacion = $Panel2/Explicacion # Asume que es un Label o RichTextLabel

# --- Propiedades de Flotación ---
@export var amplitud: float = 13.0
@export var velocidad: float = 0.9

# Guardarán las posiciones Y originales para centrar el movimiento
var setup_pos_inicial_y: float = 0.0
var loop_pos_inicial_y: float = 0.0

# --- Textos de Explicación ---
const TEXTO_SETUP = "Esta función se ejecuta SOLO UNA VEZ al iniciar la placa Arduino.

Su propósito es la Configuración Inicial. Aquí se definen los pines que serán usados como entradas o salidas (con el comando pinMode) y se inicializan las conexiones (como la comunicación serial)."
const TEXTO_LOOP = "Esta función se ejecuta CONTINUAMENTE en un ciclo infinito después de que setup() termina.

Es el Motor de tu programa. Aquí se escribe la lógica central del proyecto: leer sensores, tomar decisiones (if), y ejecutar acciones de forma repetitiva."

func _ready():
    # 1. Guardar las posiciones Y originales
    setup_pos_inicial_y = Setup.position.y
    loop_pos_inicial_y = Loop.position.y
    
    # Opcional: Mostrar una explicación inicial o dejarlo vacío
    explicacion.text = "Haz clic en SETUP o LOOP para ver su función."
    
    # Asegúrate de que las señales de los botones estén conectadas correctamente.
    # Si tus paneles son Controles simples, debes tener un Button dentro de ellos
    # que es el que emite la señal. Si los paneles son los botones, ignora esto.

func _process(delta: float):
    var tiempo = Time.get_ticks_msec() / 1000.0

    # --- Movimiento vertical (flotación) ---
    var desplazamiento = sin(tiempo * velocidad) * amplitud
    Setup.position.y = setup_pos_inicial_y + desplazamiento
    Loop.position.y = loop_pos_inicial_y - desplazamiento

    # --- Inclinación suave (rotación) ---
    var inclinacion = sin(tiempo * (velocidad * 0.7)) * 6.0  # grados
    Setup.rotation_degrees = inclinacion
    Loop.rotation_degrees = -inclinacion



# ======================================================
# 🔹 HANDLERS DE BOTONES
# ======================================================

func _on_button_setup_pressed() -> void:
    # Muestra la explicación de SETUP
    explicacion.text = TEXTO_SETUP

func _on_button_loop_pressed() -> void:
    # Muestra la explicación de LOOP
    explicacion.text = TEXTO_LOOP
