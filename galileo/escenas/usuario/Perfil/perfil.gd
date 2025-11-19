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
	var foto_id = user.get("foto", "default")  # <-- esto ya tiene el valor guardado en Globals.user

	# Ruta local de la imagen
	var ruta = "res://assets/sprites/trophies/%s" % foto_id

	if ResourceLoader.exists(ruta):
		profile_pic.texture = load(ruta)
	else:
		# Si no existe el archivo, usar la imagen por defecto
		profile_pic.texture = load("res://assets/sprites/ui/Logros/el minino resiste.png")


func _on_editar_perfil_pressed():
	get_tree().change_scene_to_file("res://escenas/usuario/Perfil/EditarPerfil.tscn")
