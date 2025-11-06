extends Control

@onready var foto = $fotoPerfil
@onready var foto_btn = $ed_foto

@onready var nombre_label = $NombreUsuario
@onready var nombre_input = $NombreInput
@onready var nombre_editar_btn = $ed_nombre

@onready var contrasena_label = $contraseña
@onready var contrasena_input = $ContrasenaInput
@onready var contrasena_editar_btn = $ed_contraseña

@onready var guardar_btn = $guardar
@onready var cerrar_btn = $cerrarSesion
@onready var borrar_btn = $borrarCuenta

var auth

func _ready():
	nombre_input.hide()
	contrasena_input.hide()
	nombre_input.hide()
	nombre_editar_btn.pressed.connect(_on_editar_nombre)
	nombre_editar_btn.pressed.connect(_on_editar_nombre)
	contrasena_editar_btn.pressed.connect(_on_editar_contrasena)
	foto_btn.pressed.connect(_on_editar_foto)
	guardar_btn.pressed.connect(_on_guardar)
	cerrar_btn.pressed.connect(_on_cerrar_sesion)
	borrar_btn.pressed.connect(_on_borrar_cuenta)

	_update_ui()
	
func _on_editar_nombre():
	nombre_input.text = nombre_label.text
	nombre_label.hide()
	nombre_input.show()
	nombre_input.grab_focus()
	
func _update_ui():
	nombre_label.text = Global.user_data.get("nombre", "")
	contrasena_label.text = "********"
	if Global.user_data.has("foto"):
		var tex = ImageTexture.new()
		tex.create_from_image(Global.user_data["foto"])
		foto.texture = tex

func _on_editar_contrasena():
	contrasena_label.hide()
	contrasena_input.show()
	contrasena_input.text = ""
	contrasena_input.grab_focus()

func _on_editar_foto():
	var file = FileDialog.new()
	file.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file.access = FileDialog.ACCESS_FILESYSTEM
	file.filters = ["*.png ; PNG", "*.jpg ; JPG"]
	add_child(file)
	file.connect("file_selected", Callable(self, "_on_foto_selected"))
	file.popup_centered()

func _on_foto_selected(path):
	var img = Image.new()
	img.load(path)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	foto.texture = tex
	Global.user_data["foto"] = img

# --- Guardar cambios ---
func _on_guardar():
	var nuevo_nombre = nombre_input.text.strip_edges() if nombre_input.visible else nombre_label.text
	var nueva_contrasena = contrasena_input.text.strip_edges() if contrasena_input.visible else null


	var updated_data = Global.user_data.duplicate()
	updated_data["nombre"] = nuevo_nombre

	await auth.save_user_data(Global.user_uid, updated_data)
	Global.user_data = updated_data

	nombre_label.text = nuevo_nombre
	nombre_label.show()
	nombre_input.hide()

	if nueva_contrasena != null and nueva_contrasena != "":
		await auth.change_password(Global.user_uid, nueva_contrasena)

	contrasena_label.show()
	contrasena_input.hide()
	contrasena_input.text = ""

func _on_cerrar_sesion():
	Global.user_data = {}
	Global.user_uid = ""
	get_tree().change_scene_to_file("res://escenas/usuario/Login/login.tscn")

func _on_borrar_cuenta():
	await auth.delete_user(Global.user_uid)
	await auth.delete_user_data(Global.user_uid)
	_on_cerrar_sesion()
