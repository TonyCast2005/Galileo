extends Control

@onready var http = $HTTPRequestFirebase
@onready var username_input = $CenterContainer/VBoxContainer/username_input
@onready var password_input = $CenterContainer/VBoxContainer/password_input
@onready var message_label = $CenterContainer/VBoxContainer/mensaje
@onready var login_button = $CenterContainer/VBoxContainer/login_button
@onready var register_button = $CenterContainer/VBoxContainer/register_button

var usuario_actual = ""   # Para saber a qué usuario estamos consultando

func _ready():
    login_button.pressed.connect(on_login_pressed)
    register_button.pressed.connect(_on_register_button_pressed)
    http.request_completed.connect(_on_HTTPRequestFirebase_request_completed)

# Este se activa cuando presionas el botón
func on_login_pressed():
    var usuario = username_input.text.strip_edges()
    var contrasena = password_input.text.strip_edges()

    if usuario == "" or contrasena == "":
        message_label.text = "⚠️ Ingresa usuario y contraseña"
        message_label.modulate = Color.ORANGE
        return

    # Traer todos los usuarios
    var url = "https://galileo-af640-default-rtdb.firebaseio.com/usuarios.json"
    var err = http.request(url, [], HTTPClient.METHOD_GET)
    if err != OK:
        message_label.text = "Error al conectar"
        message_label.modulate = Color.RED
    else:
        message_label.text = "🔎 Verificando usuario..."
        message_label.modulate = Color.YELLOW

# Manejador de la respuesta
func _on_HTTPRequestFirebase_request_completed(result, response_code, headers, body):
    if response_code == 200:
        var texto = body.get_string_from_utf8()
        var datos = JSON.parse_string(texto)

        if not datos:
            # El usuario no existe
            message_label.text = "❌ Usuario no encontrado"
            message_label.modulate = Color.RED
            return

        # Usuario existe, verificar contraseña
        var pass_guardada = datos.get("password", "")
        if pass_guardada == password_input.text:
            # Guardar datos en global
            User_Globaldata.usuario = usuario_actual
            User_Globaldata.password = pass_guardada

            # Mostrar mensaje de éxito antes de cambiar de escena
            message_label.text = "✅ Sesión iniciada"
            message_label.modulate = Color.GREEN

            await get_tree().create_timer(1.0).timeout
            get_tree().change_scene_to_file("res://scenes/ui/usuario/profile.tscn")
        else:
            message_label.text = " Contraseña incorrecta"
            message_label.modulate = Color.RED
    else:
        message_label.text = "Error al conectar (%s)" % str(response_code)
        message_label.modulate = Color.RED

func _on_register_button_pressed():
    get_tree().change_scene_to_file("res://scenes/ui/usuario/registro.tscn")
