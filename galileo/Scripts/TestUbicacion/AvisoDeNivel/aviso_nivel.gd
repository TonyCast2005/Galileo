extends Control

@onready var label_nivel = $LabelNivel


func _ready():
    var resultado = Globals.get("resultado_examen")
    var puntaje = resultado["puntaje"]
    var nivel = resultado["nivel"]

    label_nivel.text =  nivel
   


func _on_continuar_pressed():
            get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")

    
