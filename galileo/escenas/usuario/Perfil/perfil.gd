extends Control

@onready var achievements_list = $ScrollContainer/logrosVbox
@onready var http = $HTTPRequest

var LogroScene = preload("res://escenas/usuario/Perfil/Logro.tscn")
var firebase_url = "https://galileo-af640-default-rtdb.firebaseio.com/" 

var logros = {}

func _ready():
    # Pedimos los logros globales
    var url_logros = "%s/logros.json" % firebase_url
    http.request(url_logros)

# Este método recibe TODAS las respuestas de HTTPRequest
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
    if response_code != 200:
        push_error("Error al cargar Firebase: %s" % response_code)
        return

    var data = {}
    if body.size() > 0:
        data = JSON.parse_string(body.get_string_from_utf8())
    
    if data == null:
        push_error("Error al parsear JSON")
        return

    # Guardamos los logros
    logros = data

    # Mostramos todos los logros como desbloqueados
    mostrar_logros()

func mostrar_logros():
    # Limpiamos la lista antes de recargar
    for child in achievements_list.get_children():
        child.queue_free()

    for id in logros.keys():
        var data = logros[id]
        var icon = load(data["icono"]) # carga la textura desde la ruta
        add_achievement(icon, data["nombre"], data["descripcion"], true) # desbloqueado por defecto

func add_achievement(icon: Texture, title: String, description: String, unlocked: bool):
    var logro = LogroScene.instantiate()
    achievements_list.add_child(logro)
    logro.call_deferred("set_data", icon, title, description, unlocked)
