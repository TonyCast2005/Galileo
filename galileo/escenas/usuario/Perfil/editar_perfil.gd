extends Control

@onready var lineedit_nombre = $LineEditNombre
@onready var btn_editar = $BtnEditar
@onready var btn_guardar = $BtnGuardar
@onready var mensaje = $Mensaje

var auth = preload("res://escenas/usuario/registro/firebase_auth.gd").new()

func _ready():
	if Globals.is_logged_in():
		lineedit_nombre.text = str(Globals.user["nombre"])
	else:
		mensaje.text = "No hay sesión activa"
		return
	
	lineedit_nombre.editable = false
	btn_guardar.disabled = true

func _on_BtnEditar_pressed():
	lineedit_nombre.editable = true
	btn_guardar.disabled = false

func _on_BtnGuardar_pressed():
	if not Globals.is_logged_in():
		mensaje.text = "No hay sesión activa"
		return
	
	var nuevo_nombre = lineedit_nombre.text.strip_edges()
	if nuevo_nombre == "":
		mensaje.text = "El nombre no puede estar vacío"
		return
	
	var uid = Globals.user["uid"]
	var result = await auth.update_user_data(uid, {"nombre": nuevo_nombre})
	
	if result.has("error"):
		mensaje.text = "Error al actualizar: %s" % result["error"]
	else:
		mensaje.text = "Nombre actualizado correctamente"
		Globals.user["nombre"] = nuevo_nombre
		lineedit_nombre.editable = false
		btn_guardar.disabled = true
