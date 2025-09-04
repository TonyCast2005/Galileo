extends Control

# Botón para ir al perfil y reiniciar nivel
func _on_btn_empezar_desde_cero_pressed():

    get_tree().change_scene("res://scenes/ui/usuario/profile.tscn")  # abre el perfil

# Botón para iniciar el test
func _on_btn_hacer_test_pressed():
    get_tree().change_scene("res://scenes/ui/test/TestInstrucciones.tscn")  # abre el test

# Guardar nivel en Firebase
