extends Control

@onready var foto = $FotoPerfil
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

# Escena de selección de fotos
@onready var contenedor_fotos = preload("res://escenas/usuario/Perfil/imagenes.tscn")

func _ready():
    nombre_input.hide()
    contrasena_input.hide()
    nombre_input.hide()

    # Conectar señales
    nombre_editar_btn.pressed.connect(_on_editar_nombre)
    contrasena_editar_btn.pressed.connect(_on_editar_contrasena)
    foto_btn.pressed.connect(_on_editar_foto)
    guardar_btn.pressed.connect(_on_guardar)
    cerrar_btn.pressed.connect(_on_cerrar_sesion)
    borrar_btn.pressed.connect(_on_borrar_cuenta)

    _update_ui()

# -------------------------------------------------------------
# ACTUALIZAR DATOS VISUALES
# -------------------------------------------------------------
func _update_ui():
    nombre_label.text = Global.user_data.get("nombre", "")
    contrasena_label.text = "********"

    var foto_nombre = Global.user_data.get("foto_perfil", "")
    if foto_nombre != "":
        var ruta = "res://imagenes_perfil/%s" % foto_nombre
        if FileAccess.file_exists(ruta):
            var img = Image.new()
            img.load(ruta)
            var tex = ImageTexture.new()
            tex.create_from_image(img)
            foto.texture = tex

# -------------------------------------------------------------
# EDITAR NOMBRE
# -------------------------------------------------------------
func _on_editar_nombre():
    nombre_input.text = nombre_label.text
    nombre_label.hide()
    nombre_input.show()
    nombre_input.grab_focus()

# -------------------------------------------------------------
# EDITAR CONTRASEÑA
# -------------------------------------------------------------
func _on_editar_contrasena():
    contrasena_label.hide()
    contrasena_input.show()
    contrasena_input.text = ""
    contrasena_input.grab_focus()

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

    var img = Image.new()
    img.load(ruta)
    var tex = ImageTexture.new()
    tex.create_from_image(img)
    foto.texture = tex

    # Guardar el nombre en memoria global
    Global.user_data["foto_perfil"] = nombre_foto

    # Guardar cambios en Firebase
    var updated_data = Global.user_data.duplicate()
    await Auth.save_user_data(Global.user_uid, updated_data)
    Global.user_data = updated_data

    # Cerrar el selector (si existe)
    if has_node("perfil_fotos"):
        get_node("perfil_fotos").queue_free()

# -------------------------------------------------------------
# GUARDAR CAMBIOS
# -------------------------------------------------------------
func _on_guardar():
    var nuevo_nombre = nombre_input.text.strip_edges() if nombre_input.visible else nombre_label.text
    var nueva_contrasena = contrasena_input.text.strip_edges() if contrasena_input.visible else null

    var updated_data = Global.user_data.duplicate()
    updated_data["nombre"] = nuevo_nombre

    # Guardar en Firebase
    await Auth.save_user_data(Global.user_uid, updated_data)
    Global.user_data = updated_data

    # Actualizar interfaz
    nombre_label.text = nuevo_nombre
    nombre_label.show()
    nombre_input.hide()

    if nueva_contrasena != null and nueva_contrasena != "":
        await Auth.change_password(Global.user_uid, nueva_contrasena)

    contrasena_label.show()
    contrasena_input.hide()
    contrasena_input.text = ""

# -------------------------------------------------------------
# CERRAR SESIÓN
# -------------------------------------------------------------
func _on_cerrar_sesion():
    Global.user_data = {}
    Global.user_uid = ""
    get_tree().change_scene_to_file("res://escenas/usuario/Login/login.tscn")

# -------------------------------------------------------------
# BORRAR CUENTA
# -------------------------------------------------------------
func _on_borrar_cuenta():
    await Auth.delete_user(Global.user_uid)
    await Auth.delete_user_data(Global.user_uid)
    _on_cerrar_sesion()

func _on_perfil_pressed():
    get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")
