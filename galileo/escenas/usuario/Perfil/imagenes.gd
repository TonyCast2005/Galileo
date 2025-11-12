extends Control
signal foto_seleccionada(nombre_foto)

func _on_salir_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")

func _on_aprendiz_veloz_pressed() -> void:
	emit_signal("foto_seleccionada", "aprendizVeloz.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")

func _on_visual_pressed() -> void:
	emit_signal("foto_seleccionada", "amprendizVisual.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_caja_pressed() -> void:
	emit_signal("foto_seleccionada", "cajadecartón.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_gatocaja_pressed() -> void:
	emit_signal("foto_seleccionada", "catbox.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_bugs_pressed() -> void:
	emit_signal("foto_seleccionada", "cazadorDeBugs.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_noche_pressed() -> void:	
	emit_signal("foto_seleccionada", "noche.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_experto_pressed() -> void:
	emit_signal("foto_seleccionada", "expertoEnArduino.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_explorador_pressed() -> void:
	emit_signal("foto_seleccionada", "ExploradorInalcanzable.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_pelea_techo_pressed() -> void:
	emit_signal("foto_seleccionada", "PeleaTecho.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_velocista_pressed() -> void:
	emit_signal("foto_seleccionada", "gatoVelocista.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_pez_gordo_pressed() -> void:
	emit_signal("foto_seleccionada", "PezGordo.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_pwm_pressed() -> void:
	emit_signal("foto_seleccionada", "PWM.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_libros_pressed() -> void:
	emit_signal("foto_seleccionada", "teoricoNato.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
	
func _on_primera_presa_pressed() -> void:
	emit_signal("foto_seleccionada", "primeraPresa.png")
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
