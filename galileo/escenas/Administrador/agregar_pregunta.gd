extends Control

func _on_construir_codigo_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/construirCodigo.tscn")

func _on_opc_multiple_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/opcionMultiple.tscn")

func _on_vo_f_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/verdaderoFalso.tscn")

func _on_preguntas_abiertas_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/preguntasAbiertas.tscn")

func _on_preguntas_semi_abiertas_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/preguntasSemiAbiertas.tscn")

func _on_practica_escritura_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/practicaEscritura.tscn")

func _on_arrastrar_y_soltar_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/arrastrarSoltar.tscn")

func _on_codigo_con_errores_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/codigoConErrores.tscn")

func _on_construir_codigos_pressed():
	get_tree().change_scene_to_file("res://escenas/Administrador/construirCodigo.tscn")
