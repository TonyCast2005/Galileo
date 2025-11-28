extends Control

# 🌟 1. Variable clave para el mapeo de métricas 🌟
# "SA" está mapeado a la metodología "Descubrimiento" en MetricsManager.gd
const EXERCISE_TYPE = "SA"

# Panel retroalimentación (tipo OM/VF)
@onready var panel_retro: Control = $PanelRetroalimentacion
@onready var label_retro: Label = $PanelRetroalimentacion/LabelRetroalimentacion
@onready var image_retro: TextureRect = $PanelRetroalimentacion/Galileo
@onready var color_rect: ColorRect = $PanelRetroalimentacion/ColorRect
@onready var boton_retro: Button = $PanelRetroalimentacion/BotonSiguiente

# Preguntas
@onready var texto_pregunta1: Label = $TextoPregunta1
@onready var texto_pregunta2: Label = $TextoPregunta2
@onready var entrada_respuesta = $respuesta
@onready var boton_validar: Button = $validar
@onready var boton_pista: Button = $Pista
@onready var nombre_leccion: Label = $NombreLección
@onready var http: HTTPRequest = $HTTPRequest

var escena_pista: PackedScene = preload("res://escenas/Pistas/Pistas_Contenedor.tscn")
const FIREBASE_URL: String = "https://galileo-af640-default-rtdb.firebaseio.com/preguntas_semiabiertas/electronica.json"

var preguntas: Array[Dictionary] = []
var preguntas_seleccionadas: Array[Dictionary] = []
var indice_actual: int = 0
var pistas_actuales: Array[String] = []

# ===============================
# Sistema de errores
# ===============================
var errores: int = 0
var errores_maximos: int = 3

# ===============================
# Animación panel retro
# ===============================
var panel_activo := false
var velocidad := 0.04
var frame_hablando := [ preload("res://assets/sprites/ui/Galileo/Feli.png") ]
var frame_idle := preload("res://assets/sprites/ui/Galileo/Galileo Base.png")

func _ready() -> void:
    boton_validar.pressed.connect(_on_validar_pressed)
    boton_pista.pressed.connect(_mostrar_pista)
    boton_retro.pressed.connect(_on_boton_retro_pressed)
    
    panel_retro.visible = false
    cargar_preguntas()

func fallar_demasiado() -> void:
    Globals.repetir_bloque = true
    get_tree().change_scene_to_file("res://escenas/Tipos_preguntas/RepiteLeccion.tscn")

# ======================================================
# Cargar preguntas desde Firebase
# ======================================================
func cargar_preguntas() -> void:
    var err: int = http.request(FIREBASE_URL)
    if err != OK:
        push_error("Error al conectar con Firebase")
        texto_pregunta1.text = "No se pudo conectar con Firebase."
        return
    http.request_completed.connect(_on_request_completed)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
    if response_code != 200:
        texto_pregunta1.text = "Error al obtener datos."
        return

    var data: Variant = JSON.parse_string(body.get_string_from_utf8())
    if typeof(data) == TYPE_ARRAY:
        for d in data:
            if typeof(d) == TYPE_DICTIONARY:
                preguntas.append(d)
    elif typeof(data) == TYPE_DICTIONARY:
        for key in data.keys():
            var item: Variant = data[key]
            if typeof(item) == TYPE_DICTIONARY:
                preguntas.append(item)

    if preguntas.is_empty():
        texto_pregunta1.text = "No hay preguntas disponibles."
        return

    # Elegimos 4 preguntas aleatorias
    var copia := preguntas.duplicate()
    copia.shuffle()
    preguntas_seleccionadas = copia.slice(0, 4)

    mostrar_pregunta()

# ======================================================
# Mostrar pregunta actual
# ======================================================
func mostrar_pregunta() -> void:
    if indice_actual >= preguntas_seleccionadas.size():
        texto_pregunta1.text = "¡Has completado todas las preguntas!"
        texto_pregunta2.text = ""
        entrada_respuesta.editable = false
        boton_validar.disabled = true
        boton_pista.visible = false

        # TERMINÓ LA LECCIÓN → REGRESAR
        if not Globals.repetir_bloque:
            var progreso_array = Globals.desbloqueados1 
            var next_lesson_index = Globals.bloque_actual

            if next_lesson_index >= 0 and next_lesson_index < progreso_array.size():
                progreso_array[next_lesson_index] = true
            else:
                print("AVISO: Índice de desbloqueo (", next_lesson_index, ") fuera de rango.")
            
            if Globals.bloque_actual < progreso_array.size() - 1:
                Globals.bloque_actual += 1
        else:
            Globals.repetir_bloque = false	

        get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")
        return

    var p: Dictionary = preguntas_seleccionadas[indice_actual]
    texto_pregunta1.text = p.get("pregunta", "Pregunta no disponible")
    texto_pregunta2.text = p.get("subpregunta", "")
    entrada_respuesta.text = ""
    
    if p.has("pistas") and typeof(p["pistas"]) == TYPE_ARRAY:
        pistas_actuales = []
        for pista in p["pistas"]:
            pistas_actuales.append(String(pista))
    else:
        pistas_actuales = []

    boton_pista.visible = pistas_actuales.size() > 0

# ======================================================
# Normalizar texto
# ======================================================
func normalizar(s: String) -> String:
    var t := s.strip_edges().to_lower()
    var acentos := {"á":"a","é":"e","í":"i","ó":"o","ú":"u","ñ":"n"}
    for a in acentos.keys():
        t = t.replace(a, acentos[a])
    return t

# ======================================================
# Validar respuesta
# ======================================================
func _on_validar_pressed() -> void:
    var p: Dictionary = preguntas_seleccionadas[indice_actual]
    var correcta: String = normalizar(p.get("respuesta_correcta", ""))
    var usuario: String = normalizar(entrada_respuesta.text)
    var is_correct = (usuario == correcta)

    var texto: String
    var color: Color
    if is_correct:
        texto = "✔ ¡Correcto!"
        color = Color(0,1,0)
    else:
        texto = "✖ Incorrecto. La respuesta era: " + p.get("respuesta_correcta","")
        color = Color(1,0,0)
        errores += 1

    MetricsManager.update_methodology_score(EXERCISE_TYPE, is_correct)
    mostrar_retroalimentacion(texto, color)

    if errores >= errores_maximos:
        fallar_demasiado()
        return

# ======================================================
# Panel retroalimentación
# ======================================================
func mostrar_retroalimentacion(texto: String, color: Color) -> void:
    if panel_activo:
        return
    panel_activo = true

    boton_pista.visible = false
    boton_pista.disabled = true

    label_retro.text = ""
    color_rect.color = color
    panel_retro.visible = true
    image_retro.visible = true
    boton_retro.visible = false
    boton_retro.disabled = true

    var vp = get_viewport_rect().size
    var h = panel_retro.size.y
    panel_retro.position.y = vp.y + h

    var tween = create_tween()
    tween.tween_property(panel_retro, "position:y", vp.y - h, 0.4)

    await get_tree().create_timer(0.2).timeout

    var hablando = true
    var pos_original = image_retro.position
    var boca_timer = get_tree().create_timer(velocidad * 2, true)
    boca_timer.timeout.connect(func():
        if hablando:
            image_retro.texture = frame_hablando[0]
    )

    var tween_gato = create_tween().set_loops()
    tween_gato.tween_property(image_retro, "position:y", pos_original.y - 8, 0.12)
    tween_gato.tween_property(image_retro, "position:y", pos_original.y, 0.12)

    for c in texto:
        label_retro.text += c
        await get_tree().create_timer(velocidad).timeout

    hablando = false
    image_retro.texture = frame_idle
    tween_gato.kill()
    image_retro.position = pos_original

    boton_retro.visible = true
    boton_retro.disabled = false

func _on_boton_retro_pressed() -> void:
    cerrar_panel()
    indice_actual += 1
    mostrar_pregunta()

func cerrar_panel() -> void:
    var vp = get_viewport_rect().size
    var h = panel_retro.size.y
    var tween = create_tween()
    tween.tween_property(panel_retro, "position:y", vp.y + h, 0.5)
    tween.tween_callback(func():
        panel_retro.hide()
        image_retro.hide()
        panel_activo = false
    )

# ======================================================
# Mostrar pista
# ======================================================
func _mostrar_pista() -> void:
    if pistas_actuales.is_empty():
        return

    var texto: String = pistas_actuales.pop_front()
    var ventana := escena_pista.instantiate()
    add_child(ventana)
    ventana.set_pista(texto)
