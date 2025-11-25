extends Control

@onready var contenedor: Control = $Carrusel
@onready var contador = $LabelContador

var temas: Array = [
    preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Arduino/Tema_Arduino.tscn"),
    preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_Electronica/Tema_ElectronicaBasica.tscn"),
    preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Temas_ProgramacionBasica/Tema_ProgramacionBasica.tscn"),
    preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Tema_EntradasDigitales/Tema_EntradasDigitales.tscn"),
    preload("res://escenas/usuario/MenuInicial/Temas_Principiante/Examen_Principiante/ExamenPrincipiante.tscn")
    
]

var indice_actual := 0
var escena_actual: Control = null
var animando := false

func _ready():
    cargar_tema(indice_actual, 0)
    # 🌟 Llamada inicial al contador 🌟
    actualizar_contador()


# ============================================================
#    CARGAR TEMA CON ANIMACIÓN TIPO "CARRUSEL"
# ============================================================
func cargar_tema(i: int, direccion: int):
    if animando:
        return
    animando = true

    var nueva_escena := temas[i].instantiate() as Control
    contenedor.add_child(nueva_escena)

    # Anclas y posiciones (sin cambios)
    nueva_escena.anchor_left = 0
    nueva_escena.anchor_right = 1
    nueva_escena.anchor_top = 0
    nueva_escena.anchor_bottom = 1
    nueva_escena.position = Vector2.ZERO

    var ancho := contenedor.size.x

    # Primera carga → sin animación
    if escena_actual == null:
        escena_actual = nueva_escena
        animando = false
        return # La actualización del contador ya se hizo en _ready()

    # Nueva escena entra desde derecha o izquierda
    nueva_escena.position = Vector2(direccion * ancho, 0)

    var tween := create_tween()

    # ... (código de animación Tween) ...
    tween.tween_property(escena_actual, "position:x", -direccion * ancho, 0.25)\
        .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

    tween.tween_property(nueva_escena, "position:x", 0, 0.50)\
        .set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

    tween.finished.connect(func():
        if escena_actual:
            escena_actual.queue_free()
        escena_actual = nueva_escena
        animando = false
        # 🌟 Llamada final al contador 🌟
        actualizar_contador()
    )


# ============================================================
#    ACTUALIZA EL CONTADOR DE PÁGINAS (Ej: 1 / 5)
# ============================================================
func actualizar_contador():
    var total_temas = temas.size()
    # El índice es 0, 1, 2, etc. Le sumamos 1 para que sea 1, 2, 3...
    var tema_actual = indice_actual + 1
    
    contador.text = str(tema_actual) + " / " + str(total_temas)


# ============================================================
#    BOTONES (sin cambios, ya que llaman a cargar_tema)
# ============================================================
func _on_siguiente_pressed():
    if animando: return
    if indice_actual < temas.size() - 1:
        indice_actual += 1
        cargar_tema(indice_actual, 1)

func _on_anterior_pressed():
    if animando: return
    if indice_actual > 0:
        indice_actual -= 1
        cargar_tema(indice_actual, -1)


func _on_ayuda_pressed() -> void:
    pass
