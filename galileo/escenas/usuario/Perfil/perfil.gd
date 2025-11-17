extends Control

@onready var username = $NombreUsuario      # Label del nombre
@onready var level_label = $NivelUsuario    # Label del nivel
@onready var profile_pic = $FotoPerfil      # TextureRect de la foto

func _ready():
    cargar_datos_usuario()

func cargar_datos_usuario():
    var user = Globals.user

    # Nombre
    username.text = user.get("nombre", "Usuario sin nombre")

    # Nivel
    level_label.text = user.get("nivel", "novato")

    # Foto de perfil
    var foto_id = user.get("foto", "default")

    # Ruta local de la imagen
    var ruta = "res://assets/perfil/%s.png" % foto_id

    if ResourceLoader.exists(ruta):
        profile_pic.texture = load(ruta)
    else:
        profile_pic.texture = load("res://assets/sprites/ui/Logros/caja de cartón .png")

func _on_editar_perfil_pressed():
    get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
