extends Control

# 🌟 Para métricas adaptativas
const EXERCISE_TYPE = "VF"

@onready var label_pregunta = $Panel/TextoPregunta
@onready var boton_v = $Verdadero
@onready var boton_f = $Falso
@onready var boton_pistas = $Pista
@onready var http := $HTTPRequest

# ------- Panel Retro (EL NUEVO SISTEMA) -------
@onready var panel_retro = $PanelRetroalimentacion
@onready var label_retro = $PanelRetroalimentacion/LabelRetroalimentacion
@onready var image_retro = $PanelRetroalimentacion/Galileo
@onready var color_rect = $PanelRetroalimentacion/ColorRect
@onready var boton_retro = $PanelRetroalimentacion/BotonSiguiente

# Animación del panel
var velocidad_texto := 0.04
var frame_hablando = [ preload("res://assets/sprites/ui/Galileo/Feli.png") ]
var frame_idle = preload("res://assets/sprites/ui/Galileo/Galileo Base.png")
var panel_activo := false

# ------- Pistas -------
var escena_pista := preload("res://escenas/Pistas/Pistas_Contenedor.tscn")

# ------- Datos -------
var pregunta_actual := {}
var preguntas_lista: Array = []

# ------- Sistema de errores -------
var errores := 0
var errores_maximos := 3

signal respondida(correcta: bool)

func _ready():
    panel_retro.visible = false
    boton_retro.pressed.connect(_cerrar_retro)

    boton_v.pressed.connect(func(): _evaluar_respuesta(true))
    boton_f.pressed.connect(func(): _evaluar_respuesta(false))
    boton_pistas.pressed.connect(_mostrar_pista)

    _iniciar_animacion_botones()
    _cargar_preguntas()


# ===============================
#           ERRORES
# ===============================
func fallar_demasiado():
    Globals.repetir_bloque = true
    get_tree().change_scene_to_file("res://escenas/Tipos_preguntas/RepiteLeccion.tscn")


# ===============================
#      CARGAR DESDE FIREBASE
# ===============================
func _cargar_preguntas():
    http.request("https://galileo-af640-default-rtdb.firebaseio.com/VerdaderoFalso/temas/ProgramacionBasica.json")

func _on_http_request_request_completed(result, code, head, body):
    if code != 200:
        print("Error al cargar VF")
        return

    var data = JSON.parse_string(body.get_string_from_utf8())
    preguntas_lista = data.values()
    preguntas_lista.shuffle()
    preguntas_lista = preguntas_lista.slice(0, 4)

    _mostrar_siguiente_pregunta()


# ===============================
#     MOSTRAR PREGUNTA
# ===============================
func _mostrar_siguiente_pregunta():
    if preguntas_lista.is_empty():
        _terminar_leccion()
        return

    pregunta_actual = preguntas_lista.pop_front()
    label_pregunta.text = pregunta_actual.get("pregunta", "Pregunta...")

func _terminar_leccion():
    var next = Globals.bloque_actual
    if next >= 0 and next < Globals.desbloqueados1.size():
        Globals.desbloqueados1[next] = true

    get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")


# ===============================
#      EVALUAR RESPUESTA
# ===============================
func _evaluar_respuesta(resp: bool):
    var correcta = (resp == pregunta_actual["respuesta_correcta"])

    MetricsManager.update_methodology_score(EXERCISE_TYPE, correcta)
    emit_signal("respondida", correcta)

    if correcta:
        _mostrar_retro("¡Correcto!", Color.GREEN)
    else:
        errores += 1
        _mostrar_retro("Incorrecto :(", Color.RED)

    if errores >= errores_maximos:
        fallar_demasiado()


# ===============================
#          PANEL RETRO
# ===============================
func _mostrar_retro(texto: String, color: Color):
    if panel_activo: return
    panel_activo = true

    boton_v.disabled = true
    boton_f.disabled = true
    boton_pistas.disabled = true

    color_rect.color = color
    panel_retro.visible = true
    image_retro.visible = true
    boton_retro.visible = false
    boton_retro.disabled = true
    label_retro.text = ""

    # Animación aparición del panel desde abajo
    var vp = get_viewport_rect().size
    var h = panel_retro.size.y
    panel_retro.position.y = vp.y + h
    var tween = create_tween()
    tween.tween_property(panel_retro, "position:y", vp.y - h, 0.4)

    await get_tree().create_timer(0.3).timeout

    # Animación del gato
    var hablando = true
    var pos_original = image_retro.position

    var boca_timer = get_tree().create_timer(velocidad_texto * 2, true)
    boca_timer.timeout.connect(func():
        if hablando:
            image_retro.texture = frame_hablando[0]
    )

    var tween_gato = create_tween().set_loops()
    tween_gato.tween_property(image_retro, "position:y", pos_original.y - 8, 0.12)
    tween_gato.tween_property(image_retro, "position:y", pos_original.y, 0.12)

    # Escribir el texto letra por letra
    for c in texto:
        label_retro.text += c
        await get_tree().create_timer(velocidad_texto).timeout

    # Terminar animación
    hablando = false
    image_retro.texture = frame_idle
    tween_gato.kill()
    image_retro.position = pos_original

    boton_retro.visible = true
    boton_retro.disabled = false


func _cerrar_retro():
    var vp = get_viewport_rect().size
    var h = panel_retro.size.y

    var tween = create_tween()
    tween.tween_property(panel_retro, "position:y", vp.y + h, 0.5)
    tween.tween_callback(func():
        panel_retro.hide()
        image_retro.hide()
        panel_activo = false

        # 🔥 VOLVER A ACTIVAR BOTONES AQUÍ
        boton_v.disabled = false
        boton_f.disabled = false
        boton_pistas.disabled = false

        _mostrar_siguiente_pregunta()
    )



# ===============================
#          PISTAS
# ===============================
func _mostrar_pista():
    if not pregunta_actual.has("pistas") or pregunta_actual["pistas"].is_empty():
        return

    var texto = str(pregunta_actual["pistas"].pop_front())
    var v = escena_pista.instantiate()
    add_child(v)
    v.set_pista(texto)


# ===============================
#     ANIMACIÓN BOTONES
# ===============================
func _iniciar_animacion_botones():
    var pos_v = boton_v.position
    var pos_f = boton_f.position

    var t1 = create_tween().set_loops()
    t1.tween_property(boton_v, "position:y", pos_v.y - 12, 1.6)
    t1.tween_property(boton_v, "position:y", pos_v.y, 1.6)

    var t2 = create_tween().set_loops()
    t2.tween_property(boton_f, "position:y", pos_f.y + 12, 1.6)
    t2.tween_property(boton_f, "position:y", pos_f.y, 1.6)
