extends Control

@onready var http = $HTTPRequest
@onready var username_label = $Panel/VBoxContainer/CenterContainer/VBoxContainer/username_label  # 👈 cambia la ruta según tu escena

func _ready():
    http.request_completed.connect(_on_HTTPRequestFirebase_request_completed)
    cargar_datos_usuario()


func cargar_datos_usuario():
    var user = User_Globaldata.usuario
    if user == "":
        username_label.text = "⚠️ No hay usuario logueado"
        return

    var url = "https://galileo-af640-default-rtdb.firebaseio.com/usuarios/%s.json" % user
    var err = http.request(url, [], HTTPClient.METHOD_GET)
    if err != OK:
        username_label.text = "Error al conectar"

func _on_HTTPRequestFirebase_request_completed(result, response_code, headers, body):
    if response_code == 200:
        var datos = JSON.parse_string(body.get_string_from_utf8())
        if datos:
            username_label.text = datos.get("username", "Sin nombre")
        else:
            username_label.text = "Usuario no encontrado"
    else:
        username_label.text = "Error (%s)" % str(response_code)


func _on_texture_button_pressed() -> void:
 get_tree().change_scene_to_file("res://scenes/ui/usuario/EditarPerfil.tscn")
