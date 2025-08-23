extends Control

@onready var http = $HTTPRequestFirebase
@onready var username_input = $CenterContainer/VBoxContainer/username_input
@onready var password_input = $CenterContainer/VBoxContainer/password_input
@onready var confirm_password_input = $CenterContainer/VBoxContainer/password_input2
@onready var message_label = $CenterContainer/VBoxContainer/message_label
@onready var register_button = $CenterContainer/VBoxContainer/register_button

func _ready():
    register_button.pressed.connect(on_register_pressed)
    http.request_completed.connect(_on_HTTPRequestFirebase_request_completed)

func on_register_pressed():
    var usuario = username_input.text.strip_edges()
    var contrasena = password_input.text
    var confirmar = confirm_password_input.text

    if usuario == "" or contrasena == "" or confirmar == "":
        mostrar_mensaje("Por favor llena todos los campos", Color.ORANGE)
        return

    if contrasena != confirmar:
        mostrar_mensaje("Las contraseñas no coinciden", Color.RED)
        return

    guardar_datos(usuario, {"password": contrasena})
    mostrar_mensaje("Guardando en Firebase...", Color.YELLOW)

func guardar_datos(usuario: String, datos: Dictionary):
    datos["username"] = usuario
    var url = "https://galileo-af640-default-rtdb.firebaseio.com/usuarios.json"
    var json_data = JSON.stringify(datos)
    var err = http.request(url, [], HTTPClient.METHOD_POST, json_data)
    if err != OK:
        mostrar_mensaje("Error al enviar datos", Color.RED)

# Evento al terminar la petición HTTP
func _on_HTTPRequestFirebase_request_completed(result, response_code, headers, body):
    if response_code == 200:
        on_register_success()
    else:
        mostrar_mensaje("Error al conectar (%s)" % str(response_code), Color.RED)

# Función que se ejecuta SOLO si el registro fue exitoso
func on_register_success():
    mostrar_mensaje("Registro exitoso. Ahora puedes iniciar sesión.", Color.GREEN)
    # Aquí puedes limpiar los campos
    username_input.text = ""
    password_input.text = ""
    confirm_password_input.text = ""
    # Incluso podrías cambiar de escena automáticamente
    get_tree().change_scene_to_file("res://scenes/Test_1.tscn")

func mostrar_mensaje(texto: String, color: Color):
    message_label.text = texto
    message_label.modulate = color
