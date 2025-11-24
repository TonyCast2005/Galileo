extends Control

@onready var contenedor = $Carrusel

var temas := [
    preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/Tema_Arduino.tscn"),
    preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Electronica/Tema_Electronica.tscn"),
    preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Temas_ProgramacionBasica/Tema_Programacion_Basica.tscn"),
    preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_EntradasDigitales/Tema_EntradasDigitales.tscn")
]

var indice_actual := 0
var escena_actual: Control = null
var animando := false  # <-- bandera para bloquear botones

func _ready():
    cargar_tema(indice_actual, 0) # posición inicial = 0

# ------------------------------
# Cargar la escena del tema actual con animación
# direccion: 1 = siguiente, -1 = anterior, 0 = inicial
# ------------------------------
func cargar_tema(i: int, direccion: int):
    if animando:
        return # ignorar si hay animación en curso
    animando = true

    var nueva_escena = temas[i].instantiate() as Control
    contenedor.add_child(nueva_escena)

    # Ajustar tamaño y anclas
    nueva_escena.anchor_left = 0.0
    nueva_escena.anchor_right = 1.0
    nueva_escena.anchor_top = 0.0
    nueva_escena.anchor_bottom = 1.0
    nueva_escena.position = Vector2.ZERO
    nueva_escena.size_flags_horizontal = Control.SIZE_FILL
    nueva_escena.size_flags_vertical = Control.SIZE_FILL

    var ancho = contenedor.size.x

    if escena_actual == null:
        nueva_escena.position = Vector2.ZERO
        escena_actual = nueva_escena
        animando = false
        return

    nueva_escena.position = Vector2(direccion * ancho, 0)

    var tween = create_tween()
    tween.tween_property(escena_actual, "position:x", -direccion * ancho, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_property(nueva_escena, "position:x", 0, 0.50).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

    tween.finished.connect(func():
        if escena_actual:
            escena_actual.queue_free()
        escena_actual = nueva_escena
        animando = false  # <-- desbloquea la interacción
    )

# ------------------------------
# Botón: Siguiente Tema
# ------------------------------
func _on_siguiente_pressed():
    if animando: return
    if indice_actual < temas.size() - 1:
        indice_actual += 1
        cargar_tema(indice_actual, 1)

# ------------------------------
# Botón: Tema Anterior
# ------------------------------
func _on_anterior_pressed():
    if animando: return
    if indice_actual > 0:
        indice_actual -= 1
        cargar_tema(indice_actual, -1)


func _on_ayuda_pressed() -> void:
    pass # Replace with function body.
