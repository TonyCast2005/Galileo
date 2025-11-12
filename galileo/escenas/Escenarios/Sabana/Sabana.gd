extends Control
@onready var principal = $Control_Instruccion
@onready var boton_bloques = $UI/Button
@onready var sprite_animal = $Animal
@onready var label_resultado = $LabelResultado
@onready var gato = $Gato
@onready var Exclamacion_img = $Exclamation  # ← Tu imagen del destello
@onready var camara_flash = $Flash  # ← Tu imagen del destello
var estado_bloques: Array = []

@onready var panel_bloques_scene = preload("res://escenas/Escenarios/Sabana/Bloques_Sabana.tscn")
var panel_bloques_instance: Node = null

@onready var photo_slots = [
    $HBoxContainer/Foto1,
    $HBoxContainer/Foto2,
    $HBoxContainer/Foto3,
    $HBoxContainer/Foto4
]
var tutorial_activo = true

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
    "hipopotamo.png"
]

var animal_actual = ""

func _ready():
    Exclamacion_img.visible = false 
    iniciar_dialogo_sabana()
    mostrar_animal_aleatorio()
   
    for card in photo_slots:
     card.visible = true
    

func iniciar_dialogo_sabana():
    var gato_dialogo = preload("res://escenas/Gato_Instrucciones/Gato_Instrucciones.tscn").instantiate()
    add_child(gato_dialogo)
    
    gato_dialogo.global_position = Vector2(0, 40)
    
    # Textura que se ve mientras habla
    gato_dialogo.textura_habla_personal = preload("res://assets/sprites/ui/Sabana/Extra/Sabana_Felix.png")
    # Textura de reposo cuando no habla
    gato_dialogo.textura_idle_personal = preload("res://assets/sprites/ui/Sabana/Extra/Feliz_OjosAbIertos.png")
    
    # Ajustar escala del Sprite según la textura
    var tamaño_deseado = Vector2(256,256)  # el tamaño que quieres en tu escena
    var tamaño_textura = gato_dialogo.textura_habla_personal.get_size()
    gato_dialogo.gato.scale = tamaño_deseado / tamaño_textura
    
    # Diálogos que quieres que diga en este escenario
    gato_dialogo.dialogos = [
    "¡Hola, explorador! 🐾 Hoy vinimos a la sabana africana.",
   
]

    # ✅ Esperar hasta que termine el diálogo
    await gato_dialogo.dialogo_terminado

    # ✅ Ahora sí: empezar a mostrar animales
    tutorial_activo = false
    mostrar_animal_aleatorio()

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
        Exclamacion()
        $Exclamation_sound.play() 
        await get_tree().create_timer(1.0).timeout
        Camaraflash()
       
        revelar_foto_animal(animal_actual.get_basename())
        await get_tree().create_timer(0.5).timeout  # espera antes de revelar
        
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

func Exclamacion():
    Exclamacion_img.visible = true
    await get_tree().create_timer(.7).timeout  # 1 segundo
    Exclamacion_img.visible = false
    
func Camaraflash():
    camara_flash.visible = true
    await get_tree().create_timer(.2).timeout  # 1 segundo
    camara_flash.visible = false

func revelar_foto_animal(animal_filename: String):
    var nombre = animal_filename.get_basename()  # "cebra.png" → "cebra"

    # Si ya llenaste los 4 espacios, no hagas nada
    if current_slot_index >= photo_slots.size():
        print("🖼️ No hay más espacios disponibles para fotos.")
        return

    # ⏳ Esperar 1 segundo antes de mostrar la foto
    await get_tree().create_timer(.4).timeout

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
    $Paper_Snap.play()  # Sonido de pop al colocar la foto
    
    t.tween_property(slot, "position", pos_final, 0.35)\
        .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    t.parallel().tween_property(slot, "modulate:a", 1.0, 0.3)
    t.parallel().tween_property(slot, "scale", Vector2(1, 1), 0.35)\
        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
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
    
    
func guardar_estado_bloques():
    if not is_instance_valid(panel_bloques_instance):
        return

    estado_bloques.clear()
    for bloque in panel_bloques_instance.get_tree().get_nodes_in_group("bloques"):
        estado_bloques.append({
            "tipo": bloque.palabra,
            "pos": bloque.global_position
        })
    print("💾 Estado guardado:", estado_bloques)



func restaurar_estado_bloques():
    if estado_bloques.is_empty():
        return

    await get_tree().process_frame

    # 🔹 Marcar que los bloques están restaurando para no reubicarse
    for bloque in panel_bloques_instance.get_tree().get_nodes_in_group("bloques"):
        bloque.restaurando = true

    # 🔹 Restaurar posiciones guardadas
    for data in estado_bloques:
        for bloque in panel_bloques_instance.get_tree().get_nodes_in_group("bloques"):
            if bloque.palabra == data["tipo"]:
                bloque.global_position = data["pos"]

    print("🔁 Estado restaurado.")

    
func _on_boton_bloques_pressed() -> void:
       toggle_panel_bloques()
    

    
func toggle_panel_bloques():
    if panel_bloques_instance == null:
        # --- Abrir panel ---
        panel_bloques_instance = panel_bloques_scene.instantiate()

        # 🔹 Antes de agregar al árbol, marcamos todos los bloques como "restaurando"
        for bloque in panel_bloques_instance.get_tree().get_nodes_in_group("bloques"):
            bloque.restaurando = true

        # 🔹 Ahora sí, agregamos la escena al árbol
        get_tree().root.add_child(panel_bloques_instance)

        # Esperamos un frame para asegurarnos de que esté inicializada
        await get_tree().process_frame

        # 🔹 Restaurar posiciones guardadas (si hay)
        restaurar_estado_bloques()

        # Pequeño fade-in visual
        panel_bloques_instance.modulate.a = 0.0
        var tween = create_tween()
        tween.tween_property(panel_bloques_instance, "modulate:a", 1.0, 0.3)

    else:
        # --- Cerrar panel ---
        if is_instance_valid(panel_bloques_instance):
            # 🔹 Guardar estado actual antes de cerrarlo
            guardar_estado_bloques()

            var tween = create_tween()
            tween.tween_property(panel_bloques_instance, "modulate:a", 0.0, 0.2)
            tween.tween_callback(func():
                if is_instance_valid(panel_bloques_instance):
                    panel_bloques_instance.queue_free()
                panel_bloques_instance = null)
