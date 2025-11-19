extends Control

@onready var foto = $FotoPerfil
@onready var foto_btn = $ed_foto
@onready var perfil_btn = $ed_foto
var nombre
var password
signal foto_cambiada(nueva_foto)

# Escena de selección de fotos
@onready var contenedor_fotos = preload("res://escenas/usuario/Perfil/contenedores_editar/imagenes.tscn")
@onready var contenedor_nombre = preload("res://escenas/usuario/Perfil/contenedores_editar/contenedor_nombre.tscn")
@onready var contenedor_contra = preload("res://escenas/usuario/Perfil/contenedores_editar/contenedor_contra.tscn")

func _ready():
	# Conectar botón para abrir selector de fotos
	foto_btn.pressed.connect(_on_editar_foto)
	Globals.connect("foto_actualizada", Callable(self, "_on_foto_actualizada"))
   
	# Actualizar imagen inicial
	_update_foto()
	cargar_datos_usuario()

# -------------------------------------------------------------
# ACTUALIZAR FOTO EN LA INTERFAZ
# -------------------------------------------------------------
# Perfil

func _update_foto():
	var foto_nombre = Globals.user.get("foto", "")
	var ruta = "res://imagenes_perfil/%s" % foto_nombre

	if FileAccess.file_exists(ruta):
		var img = Image.new()
		img.load(ruta)
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		foto.texture = tex

# -------------------------------------------------------------
# ABRIR SELECCIONADOR DE FOTO
# -------------------------------------------------------------
func _on_editar_foto():
	var selector = contenedor_fotos.instantiate()
	add_child(selector)
	selector.connect("foto_seleccionada", Callable(self, "_on_foto_elegida"))

# -------------------------------------------------------------
# FOTO ELEGIDA (señal recibida del selector)
# -------------------------------------------------------------
func _on_foto_elegida(nombre_foto: String):
	var ruta = "res://imagenes_perfil/%s" % nombre_foto
	if not FileAccess.file_exists(ruta):
		push_warning("La imagen seleccionada no existe: %s" % ruta)
		return

	# Actualizar interfaz
	var img = Image.new()
	img.load(ruta)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
   
   # Guardar en Globals usando la misma clave que usas en toda la app
	Globals.user["foto"] = nombre_foto
	Globals.emit_signal("foto_cambiada", nombre_foto)

	# Guardar en Firebase
	var auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)
	var uid = Globals.user.get("uid", "")
	if uid != "":
		var res = await auth.update_user_data(uid, {"foto": nombre_foto})
		if res.has("error"):
			push_error("Error al guardar la foto en Firebase: %s" % res["error"])
		else:
			print("Foto actualizada correctamente:", nombre_foto)
	
	# Cerrar selector
	if has_node("perfil_fotos"):
		get_node("perfil_fotos").queue_free() 

func _on_perfil_pressed() -> void:
		get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")


func cargar_datos_usuario():
	var user = Globals.user

	# Nombre
	nombre = user.get("nombre", "Usuario sin nombre")

	# Foto de perfil
	var foto_id = user.get("foto", "default")  # <-- esto ya tiene el valor guardado en Globals.user

	# Ruta local de la imagen
	var ruta = "res://assets/sprites/trophies/%s" % foto_id

	if ResourceLoader.exists(ruta):
		foto.texture = load(ruta)
	else:
		# Si no existe el archivo, usar la imagen por defecto
		foto.texture = load("res://assets/sprites/ui/Logros/el minino resiste.png")


func _on_foto_actualizada(foto_nueva: String):
	print("Nueva foto recibida:", foto_nueva)
	cargar_datos_usuario()   # recarga la foto desde Globals.user


func _on_ed_nombre_pressed() -> void:
	var selector = contenedor_nombre.instantiate()
	add_child(selector)
	selector.connect("foto_seleccionada", Callable(self, "_on_foto_elegida"))
	
func _on_ed_contraseña_pressed() -> void:
	var selector = contenedor_contra.instantiate()
	add_child(selector)
	selector.connect("foto_seleccionada", Callable(self, "_on_foto_elegida"))
	
func _on_cerrar_sesion_pressed() -> void:
	Globals.user.clear()
	get_tree().change_scene_to_file("res://escenas/usuario/registro/iniciarSesion.tscn")
