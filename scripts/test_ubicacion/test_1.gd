extends Control

func _on_btn_empezar_desde_cero_pressed():
    # Guarda nivel novato
    Global.user_id = obtener_usuario_actual()  # tu método para obtener user_id
    asignar_nivel("novato")
    get_tree().change_scene("res://MenuPrincipal.tscn")

func _on_btn_hacer_test_pressed():
    get_tree().change_scene("res://TestInstrucciones.tscn")

func asignar_nivel(nivel: String):
    var url = "https://TU_PROYECTO.firebaseio.com/usuarios/%s/nivel.json" % Global.user_id
    var body = JSON.print(nivel)
    var headers = ["Content-Type: application/json"]
    $HTTPRequest.request(url, headers, true, HTTPClient.METHOD_PUT, body)
