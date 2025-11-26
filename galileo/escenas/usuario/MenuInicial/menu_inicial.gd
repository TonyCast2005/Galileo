extends Control

@onready var contenedor: Control = $Carrusel
@onready var contador: Label = $LabelContador

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
var current_tween   # ← sin tipo, sin valor inicial

func start_animation():
    if current_tween:
        current_tween.kill()

    current_tween = get_tree().create_tween()
    current_tween.tween_property($Label, "modulate:a", 1.0, 1.0)


func _ready():
    cargar_tema(indice_actual, 0)
    actualizar_contador()


func cargar_tema(i: int, direccion: int):
    if animando:
        return
    animando = true

    # Limpiar tween previo
    if current_tween != null:
        if typeof(current_tween) == TYPE_OBJECT and current_tween.is_valid():
            current_tween.kill()
        current_tween = null

    # Instanciar nueva escena
    var nueva_escena: Control = temas[i].instantiate() as Control
    contenedor.add_child(nueva_escena)

    # Configurar anclas y posición
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
        return

    # Nueva escena entra por izquierda o derecha
    nueva_escena.position = Vector2(direccion * ancho, 0)

    var old_scene := escena_actual

    # Crear tween
    var tween := create_tween()
    current_tween = tween

    # Animar escena anterior sólo si sigue viva
    if is_instance_valid(old_scene):
        tween.tween_property(old_scene, "position:x", -direccion * ancho, 0.25)\
            .set_trans(Tween.TRANS_QUAD)\
            .set_ease(Tween.EASE_IN)

    # Animar nueva escena
    tween.tween_property(nueva_escena, "position:x", 0, 0.50)\
        .set_trans(Tween.TRANS_ELASTIC)\
        .set_ease(Tween.EASE_OUT)

    # Actualizar contador
    actualizar_contador()

    # Al terminar animación
    tween.finished.connect(func():
        if is_instance_valid(old_scene):
            old_scene.queue_free()

        escena_actual = nueva_escena
        animando = false
        current_tween = null
    )


func actualizar_contador():
    var total_temas = temas.size()
    var tema_actual = indice_actual + 1
    contador.text = str(tema_actual) + " / " + str(total_temas)


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
