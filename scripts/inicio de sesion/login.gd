extends Control

@onready var http = $HTTPRequestFirebase
@onready var username_input = $CenterContainer/VBoxContainer/username_input
@onready var password_input = $CenterContainer/VBoxContainer/password_input
@onready var message_label = $CenterContainer/VBoxContainer/message_label
@onready var login_button = $CenterContainer/VBoxContainer/login_button
@onready var register_button = $CenterContainer/VBoxContainer/register_button

func _ready():
    login_button.pressed.connect(on_login_pressed)
    register_button.pressed.connect(_on_register_button_pressed)
    http.request_completed.connect(_on_HTTPRequestFirebase_request_completed)

# Este se activa cuando presionas el botón
func on_login_pressed():
    var usuario = username_input.text
    var contrasena = password_input.text

    # Guardamos usuario y contraseña en Firebase
    guardar_datos(usuario, {"password": contrasena})
    # También podrías verificar antes si existe, pero por ahora lo guardamos directo (como registro)

    message_label.text = "Guardando en Firebase..."
    message_label.modulate = Color.YELLOW

# Guarda los datos del usuario
func guardar_datos(usuario: String, datos: Dictionary):
    var url = "https://galileo-af640-default-rtdb.firebaseio.com/usuarios/%s.json" % usuario
    var json_data = JSON.stringify(datos)
    var err = http.request(url, [], HTTPClient.METHOD_PUT, json_data)
    if err != OK:
        message_label.text = "Error al enviar datos"
        message_label.modulate = Color.RED

# Manejador de la respuesta
func _on_HTTPRequestFirebase_request_completed(result, response_code, headers, body):
    if response_code == 200:
        var texto = body.get_string_from_utf8()
        var datos = JSON.parse_string(texto)

        if datos:
            User_Globaldata.usuario = username_input.text
            User_Globaldata.password = datos.get("password", "")

            # Mostrar mensaje de éxito antes de cambiar de escena
            message_label.text = "✅ Registrado en Firebase"
            message_label.modulate = Color.GREEN

            # Si quieres dar 1 segundo para que el usuario lo lea:
            await get_tree().create_timer(1.0).timeout

            # Cargar nueva escena
            get_tree().change_scene_to_file("res://scenes/curso.tscn")
        else:
            message_label.text = "Usuario no encontrado"
            message_label.modulate = Color.ORANGE
    else:
        message_label.text = "Error al conectar (%s)" % str(response_code)
        message_label.modulate = Color.RED

func _on_register_button_pressed():
    get_tree().change_scene_to_file("res://scenes/ui/usuario/registro.tscn")
