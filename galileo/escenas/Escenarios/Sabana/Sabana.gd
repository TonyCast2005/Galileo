extends Control
@onready var principal = $Control_Instruccion
@onready var sprite_animal = $Animal
@onready var label_resultado = $LabelResultado
@onready var gato = $Gato
@onready var flash_camara = $FlashCamara  # ← Tu imagen del destello

@onready var panel_bloques = preload("res://escenas/Escenarios/Sabana/Bloque_Animal.tscn").instantiate()
@onready var photo_slots = [
    $HBoxContainer/Foto1,
    $HBoxContainer/Foto2,
    $HBoxContainer/Foto3,
    $HBoxContainer/Foto4
]
var tutorial_activo = false

var current_photo_index = 0

var carpeta_animales = "res://assets/sprites/ui/Sabana/"
var animales = [
    "cebra.png",
    "leon.png",
    "jirafa.png",
    "elefante.png",
     "cocodrilo.png",
    "hipopotamo.png"
    
]
var fotos_tomadas = {}  # Guarda qué animales ya fueron fotografiados
var current_slot_index = 0


var animales_objetivo = [
    "cocodrilo.png",
    "hipopotamo.png",
    
   
   
]

var animal_actual = ""

func _ready():
    flash_camara.visible = false 
    mostrar_animal_aleatorio()
    iniciar_tutorial()
    for card in photo_slots:
     card.visible = true


func mostrar_animal_aleatorio():
    if tutorial_activo:
        return  # No hacer nada mientras el tutorial esté activo

    animal_actual = animales.pick_random()
    sprite_animal.texture = load(carpeta_animales + animal_actual)
    sprite_animal.position = Vector2(200, 300)
    
    animar_salto_inicial()

    if animal_actual in animales_objetivo:
        label_resultado.text = "📸 ¡El gato tomó foto a la " + animal_actual.get_basename() + "!"
        animar_gato()
        mostrar_flash()
        revelar_foto_animal(animal_actual.get_basename())
    else:
        label_resultado.text = "El gato no tomó foto. (" + animal_actual.get_basename() + ")"

    await get_tree().create_timer(1).timeout
    mostrar_animal_aleatorio()


# 💥 ANIMACIÓN DEL SALTO DE ENTRADA (vertical)
func animar_salto_inicial():
    var pos_base = sprite_animal.position
    sprite_animal.position = pos_base + Vector2(0, 250)  # Empieza más abajo (fuera)
    
    var t = create_tween()
    # Salta hacia arriba
    t.tween_property(sprite_animal, "position", pos_base - Vector2(0, 40), 0.4)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    # Rebota hacia abajo
    t.tween_property(sprite_animal, "position", pos_base, 0.25)\
        .set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
    # Después del salto principal, iniciar movimiento lateral
    t.finished.connect(func(): animar_movimiento_lateral())


# 🌀 MOVIMIENTO CONTINUO DE LADO A LADO
func animar_movimiento_lateral():
    var pos_base = sprite_animal.position
    var t = create_tween()
    t.set_loops()
    # Movimiento suave izquierda-derecha
    t.tween_property(sprite_animal, "position:x", pos_base.x + 6, 0.2)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    t.tween_property(sprite_animal, "position:x", pos_base.x - 6, 0.2)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    t.tween_property(sprite_animal, "position:x", pos_base.x, 0.2)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# 😺 ANIMACIÓN SIMPLE DEL GATO
func animar_gato():
    var pos_ini = gato.position
    var t = create_tween()
    t.tween_property(gato, "position:y", pos_ini.y - 30, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    t.tween_property(gato, "position:y", pos_ini.y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func mostrar_flash():
    flash_camara.visible = true
    await get_tree().create_timer(1.0).timeout  # 1 segundo
    flash_camara.visible = false

func revelar_foto_animal(animal_filename: String):
    var nombre = animal_filename.get_basename()  # "cebra.png" → "cebra"

    # Si ya llenaste los 4 espacios, no hagas nada
    if current_slot_index >= photo_slots.size():
        print("🖼️ No hay más espacios disponibles para fotos.")
        return

    # Cargar la textura correspondiente al animal fotografiado
    var ruta = "res://assets/sprites/ui/Sabana/Photocards/%s_photocard.png" % nombre
    var textura = load(ruta)
    if textura == null:
        print("⚠️ No se encontró textura para", ruta)
        return

    # Asignar textura al siguiente espacio disponible
    var slot = photo_slots[current_slot_index]
    slot.texture = textura

    # --- 💫 Animación tipo "caída y pegado" ---
    var pos_final = slot.position
    slot.position = pos_final - Vector2(0, 200)   # Empieza arriba
    slot.scale = Vector2(1.2, 1.2)                # Un poco más grande
    slot.modulate = Color(1, 1, 1, 0)             # Invisible al principio
    slot.rotation_degrees = 0                     # Empieza recto

    var t = create_tween()

    # Movimiento hacia abajo
    $Paper_Snap.play()  # Sonido de pop al colocar la foto
    
    t.tween_property(slot, "position", pos_final, 0.35)\
        .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    # Aumenta opacidad
    t.parallel().tween_property(slot, "modulate:a", 1.0, 0.3)
    # Reduce suavemente la escala
    t.parallel().tween_property(slot, "scale", Vector2(1, 1), 0.35)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    # Inclinación al pegar
    t.tween_callback(func():
        var rot_tween = create_tween()
        rot_tween.tween_property(slot, "rotation_degrees", -4, 0.05)\
            .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        rot_tween.tween_property(slot, "rotation_degrees", 4, 0.12)\
            .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        rot_tween.tween_property(slot, "rotation_degrees", -4, 0.1)
        rot_tween.tween_property(slot, "rotation_degrees", 0, 0.1)
    )

    # Registrar que ya se tomó esa foto
    fotos_tomadas[nombre] = true
    current_slot_index += 1

    print("📸 Foto de", nombre, "revelada en espacio", current_slot_index)


func _empezar_juego():
    tutorial_activo = false
    mostrar_animal_aleatorio()

func iniciar_tutorial():
    var tutorial = preload("res://escenas/Gato_Instrucciones/Gato_Instrucciones.tscn").instantiate()
    add_child(tutorial)

    # 💡 Si el tutorial es un Control, lo centramos usando anclas
    if tutorial is Control:
        tutorial.anchor_left = 0.5
        tutorial.anchor_top = 0.5
        tutorial.anchor_right = 0.5
        tutorial.anchor_bottom = 0.5
        tutorial.offset_left = -tutorial.size.x / 2
        tutorial.offset_top = -tutorial.size.y / 2
        tutorial.offset_right = tutorial.size.x / 2
        tutorial.offset_bottom = tutorial.size.y / 2

    # Diálogos
    tutorial.dialogos = [
        "Hola, soy Galileo!",
        "Vamos a tomar fotos a los animales!",
        "Sigue mis instrucciones y empieza el juego!"
    ]

    tutorial.connect("tutorial_terminado", Callable(self, "_empezar_juego"))
    tutorial.iniciar_tutorial()

    
    
