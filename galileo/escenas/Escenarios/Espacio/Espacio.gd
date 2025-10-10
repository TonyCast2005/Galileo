extends Control





var tutorial_activo = true

func _ready():
 
    iniciar_dialogo_espacio()
    
    
func iniciar_dialogo_espacio():
    var gato_dialogo = preload("res://escenas/Gato_Instrucciones/Gato_Instrucciones.tscn").instantiate()
    add_child(gato_dialogo)
    
    gato_dialogo.global_position = Vector2(10, 500)
    
    # Textura que se ve mientras habla
    gato_dialogo.textura_habla_personal = preload("res://assets/sprites/ui/Espacio/Galileo_Espacio_Hablando.png")
    # Textura de reposo cuando no habla
    gato_dialogo.textura_idle_personal = preload("res://assets/sprites/ui/Espacio/Galileo_Espacio_Base.png")
    
    # Ajustar escala del Sprite según la textura
    var tamaño_deseado = Vector2(256,256)  # el tamaño que quieres en tu escena
    var tamaño_textura = gato_dialogo.textura_habla_personal.get_size()
    gato_dialogo.gato.scale = tamaño_deseado / tamaño_textura
    
    # Diálogos que quieres que diga en este escenario
    gato_dialogo.dialogos = [
    "¡Hola, astronauta! 🚀 Hoy viajamos al espacio exterior.",
    "Mira esas estrellas brillantes...",
    "Tu misión será tomar fotos de los planetas. 📸",
    "Algunos se mueven rápido, ¡así que apunta bien! 🛰️",
    "Cuando termines todas las fotos, tendrás una sorpresa estelar. 🌠"
]


    # ✅ Esperar hasta que termine el diálogo
    await gato_dialogo.dialogo_terminado

    # ✅ Ahora sí: empezar a mostrar animales
    tutorial_activo = false
