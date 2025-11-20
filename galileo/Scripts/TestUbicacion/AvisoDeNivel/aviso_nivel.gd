extends Control

@onready var label_nivel = $LabelNivel

func _ready():
    var resultado = Globals.get("resultado_examen")

    if resultado == null:
        label_nivel.text = "Sin datos"
        return

    var puntaje = resultado["resultado_examen"]["puntaje"]
    var nivel = resultado["nivel"]

    label_nivel.text = nivel


func _on_continuar_pressed():
    get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")
