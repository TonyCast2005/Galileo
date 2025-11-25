extends Control

func _on_perfil_pressed():
    get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")

func _on_leccion_pressed():
    get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")

func _on_estadistica_pressed():
    get_tree().change_scene_to_file("res://escenas/Graficas_Metricas/Metricas.tscn") 
