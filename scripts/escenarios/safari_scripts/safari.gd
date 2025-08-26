extends Control

@onready var message_label = $MessageLabel
@onready var animal_sprite = $AnimalSprite
@onready var spawn_timer = $SpawnTimer  # Timer en la escena

# Lista de animales con imagen
var animales = [
    {"tipo": "Jirafa", "color": "amarillo", "peligroso": false, "imagen": "res://assets/sprites/safari/animales/jirafa.png"},
    {"tipo": "cocodrilo", "color": "verde", "peligroso": true, "imagen":"res://assets/sprites/safari/animales/cocodrilo.png"},
    {"tipo": "elefante", "color": "gris", "peligroso": false, "imagen": "res://assets/sprites/safari/animales/elefante .png"},
    {"tipo": "cebra", "color": "blanco", "peligroso": false, "imagen": "res://assets/sprites/safari/animales/cebra.png"},
    {"tipo": "leon", "color": "naranja", "peligroso": true, "imagen": "res://assets/sprites/safari/animales/león .png"}
]

var indice_actual = 0

func _ready():
    spawn_timer.start()  # Inicia el Timer al cargar la escena

func mostrar_animal():
    if indice_actual >= animales.size():
        indice_actual = 0  

    var animal = animales[indice_actual]
    animal_sprite.texture = load(animal["imagen"])
    animal_sprite.position = get_viewport_rect().size / 2
    animal_sprite.scale = Vector2(0, 0)  # empieza invisible
    animal_sprite.modulate.a = 0  # transparencia inicial

    # Crear Tween
    var tween = create_tween()
    tween.tween_property(animal_sprite, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(animal_sprite, "modulate:a", 1.0, 0.4)
    tween.tween_property(animal_sprite, "position:y", animal_sprite.position.y - 30, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_property(animal_sprite, "position:y", animal_sprite.position.y, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

   # Cambiar mensaje
    if animal["peligroso"]:
        message_label.text = "😺 ¡Cuidado! Apareció un " + animal["tipo"]
    else:
        message_label.text = "📸 Apareció un " + animal["tipo"] + " de color " + animal["color"]

    indice_actual += 1

    
    
# Conectado al botón "NextButton" (opcional)
func _on_next_button_pressed() -> void:
    mostrar_animal()


func _on_spawn_timer_timeout() -> void:
   mostrar_animal()
