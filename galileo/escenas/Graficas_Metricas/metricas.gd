extends Control

var datos = [300, 150, 350]
var etiquetas = ["Abe", "Ejemplos", "zzzz"]

@onready var fuente = get_theme_default_font()
@onready var img1 = $Img1
@onready var img2 = $Img2
@onready var img3 = $Img3


# Carga tus imágenes
@onready var iconos = [
    preload("res://assets/sprites/ui/Logros/Pelea en el techo .png"),
    preload("res://assets/sprites/ui/Logros/Leyenda del cable masticado .png"),
    preload("res://assets/sprites/ui/Logros/de noche todos los gatos son pardos.png")
]



var imagenes = []  # Aquí guardamos los nodos TextureRect

func _ready():
    img1.custom_minimum_size = Vector2(528, 128)

    img2.custom_minimum_size = Vector2(64, 64)
    img2.custom_minimum_size = Vector2(64, 64)
    # Crear las imágenes como nodos
    for i in range(iconos.size()):
        var img = TextureRect.new()
        img.texture = iconos[i]
        img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE  # ← no deforma la imagen
        img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        img.custom_minimum_size = Vector2(40, 40)  # ← 👈 aquí controlas el tamaño
        add_child(img)
        imagenes.append(img)
    queue_redraw()

func _process(delta):
    # Posicionar cada imagen justo encima de su barra
    var ancho_barra = 90
    var espacio = 70
    var margen_inferior = 30

    for i in range(datos.size()):
        var altura = datos[i]
        var pos_x = i * (ancho_barra + espacio)
        var pos_y = size.y - altura - margen_inferior
        var img = imagenes[i]

        # Centrar y colocar encima
        img.position = Vector2(
            pos_x + (ancho_barra - img.size.x) / 2,
            pos_y - img.size.y - 10
        )

func _draw():
    var ancho_barra = 90
    var espacio = 70
    var color_barra = Color(0.2, 0.6, 1.0)
    var margen_inferior = 20

    draw_rect(Rect2(Vector2.ZERO, size), Color(0.1, 0.1, 0.1, 0.8), true)

    for i in range(datos.size()):
        var altura = datos[i]
        var pos_x = i * (ancho_barra + espacio)
        var pos_y = size.y - altura - margen_inferior
        var rect = Rect2(pos_x, pos_y, ancho_barra, altura)

        var color_dinamico = color_barra.lightened(datos[i] / 150.0)
        draw_rect(rect, color_dinamico, true)

        draw_string(fuente, Vector2(pos_x + 5, size.y - 8), etiquetas[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
        
