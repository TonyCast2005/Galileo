# WaveEffect.gd
extends RichTextEffect

# Nombre de la etiqueta BBCode que usaremos: [wave]
var bbcode = "wave"

# La función principal que Godot llamará para procesar el efecto
func _process_custom_fx(char_fx: CharFXTransform) -> bool:
    # 1. Obtener los parámetros
    var amplitude = char_fx.get_parameter("amplitude", 8.0) # Amplitud (altura de la ola)
    var speed = char_fx.get_parameter("speed", 4.0)         # Velocidad de la ola
    var frequency = char_fx.get_parameter("frequency", 0.5) # Frecuencia (qué tan espaciada está)

    # 2. Calcular el desplazamiento vertical (la 'ola')
    # char_fx.absolute_index: Índice global del caracter en todo el texto.
    # Time.get_ticks_msec() / 1000.0: Tiempo en segundos (uniforme para toda la ola).
    var time = char_fx.env.time * speed
    var offset_y = sin((char_fx.absolute_index * frequency) + time) * amplitude

    # 3. Aplicar el desplazamiento
    char_fx.offset = Vector2(0, offset_y)

    # Retorna true para indicar que el efecto se ha aplicado
    return true
