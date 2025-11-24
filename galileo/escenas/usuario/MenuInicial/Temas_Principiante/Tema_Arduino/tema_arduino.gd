extends Control

@onready var boton_1 = $Button1
@onready var boton_2 = $Button2
@onready var boton_3 = $Button3
@onready var boton_4 = $Button4

# Estado de los botones (true = desbloqueado, false = bloqueado)
var ejercicios_disponibles := [true, false, false, false]

# Rutas de escenas de ejercicios
var ejercicios_scenes := [
    "res://escenas/Temas_Principiante/Arduino/Lectura.tscn",
    "res://escenas/Temas_Principiante/Arduino/Ejercicio2.tscn",
    "res://escenas/Temas_Principiante/Arduino/Ejercicio3.tscn",
    "res://escenas/Temas_Principiante/Arduino/Ejercicio4.tscn"
]

func _ready():
    _actualizar_botones()

# -------------------------
# Actualizar visual de botones según disponibilidad
# -------------------------
func _actualizar_botones():
    var botones = [boton_1, boton_2, boton_3, boton_4]
    
    for i in range(botones.size()):
        if ejercicios_disponibles[i]:
            botones[i].disabled = false
            # Puedes cambiar el icono a desbloqueado si tienes un TextureButton
        else:
            botones[i].disabled = true
            # Cambiar icono a bloqueado
            if botones[i] is TextureButton:
                botones[i].texture_normal = preload("res://assets/sprites/ui/bloqueado.png")

# -------------------------
# Función genérica para manejar el botón presionado
# -------------------------
func _abrir_ejercicio(indice: int):
    if indice >= 0 and indice < ejercicios_scenes.size():
        get_tree().change_scene_to_file(ejercicios_scenes[indice])

# -------------------------
# Señales de los botones
# -------------------------
func _on_button_1_pressed():
    _abrir_ejercicio(0)

func _on_button_2_pressed():
    _abrir_ejercicio(1)

func _on_button_3_pressed():
    _abrir_ejercicio(2)

func _on_button_4_pressed():
    _abrir_ejercicio(3)

# -------------------------
# Llamar esta función cuando un ejercicio se completa
# -------------------------
func desbloquear_siguiente(indice: int):
    if indice + 1 < ejercicios_disponibles.size():
        ejercicios_disponibles[indice + 1] = true
        _actualizar_botones()
