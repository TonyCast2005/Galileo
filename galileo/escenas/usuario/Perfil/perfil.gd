extends Control

@onready var username = $NombreUsuario
@onready var level_label = $NivelUsuario
@onready var profile_pic = $FotoPerfil
@onready var contenedor = $ScrollContainer/logrosVbox
@onready var prefab_logro = preload("res://escenas/usuario/Perfil/Logro.tscn")

func _ready():
    cargar_logros()
    cargar_datos_usuario()

# ---------------------------------------------------
# CARGAR LOGROS DESDE FIREBASE
# ---------------------------------------------------
func cargar_logros():
    var http := HTTPRequest.new()
    add_child(http)
    http.request_completed.connect(_on_logros_recibidos)
    http.request("https://galileo-af640-default-rtdb.firebaseio.com/logros.json")

func _on_logros_recibidos(result, code, headers, body):
    if code != 200:
        print("❌ Error cargando logros:", code)
        return

    var data = JSON.parse_string(body.get_string_from_utf8())
    if typeof(data) != TYPE_DICTIONARY:
        print("⚠ Tabla de logros vacía o mal formateada")
        return

    var user_logros = Globals.user.get("logros", {})

    for clave in data.keys():
        var info = data[clave]
        if typeof(info) != TYPE_DICTIONARY:
            continue

        # --------------------------
        # CARGAR ICONO
        # --------------------------
        var icon_path = info.get("icono", "")
        var icono = load(icon_path)

        if icono == null:
            print("⚠ Icono no encontrado:", icon_path)
            icono = load("res://assets/sprites/ui/Logros/default.png")

        var nombre = info.get("nombre", "Logro sin nombre")
        var descripcion = info.get("descripcion", "Sin descripción")
        var esta_desbloqueado = user_logros.get(clave, false)

        # --------------------------------------------
        # 🔥 ORDEN CORRECTO (soluciona tu error)
        # --------------------------------------------
        var logro_instance = prefab_logro.instantiate()

        # PRIMERO agregar al árbol (así se ejecuta _ready())
        contenedor.add_child(logro_instance)

        # AHORA sí, setear los datos
        logro_instance.set_data(icono, nombre, descripcion, esta_desbloqueado)

# ---------------------------------------------------
# CARGAR DATOS DEL PERFIL
# ---------------------------------------------------
func cargar_datos_usuario():
    var user = Globals.user

    username.text = user.get("nombre", "Usuario sin nombre")
    level_label.text = user.get("nivel", "novato")

    var foto_id = user.get("foto", "default")
    var ruta = "res://assets/sprites/trophies/%s" % foto_id

    if ResourceLoader.exists(ruta):
        profile_pic.texture = load(ruta)
    else:
        profile_pic.texture = load("res://assets/sprites/ui/Logros/el minino resiste.png")

func _on_editar_perfil_pressed():
    get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
