extends Control

@onready var label_notificacion = $LabelNotificacion
@onready var foto = $FotoPerfil
@onready var foto_btn = $ed_foto
@onready var perfil_btn = $ed_foto
var nombre
var password
signal foto_cambiada(nueva_foto)

# Escena de selección de fotos/nombre/contraseña
@onready var contenedor_fotos = preload("res://escenas/usuario/Perfil/contenedores_editar/imagenes.tscn")
@onready var contenedor_nombre = preload("res://escenas/usuario/Perfil/contenedores_editar/contenedor_nombre.tscn")
@onready var contenedor_contra = preload("res://escenas/usuario/Perfil/contenedores_editar/contenedor_contra.tscn")

func _ready():
    foto_btn.pressed.connect(_on_editar_foto)
    Globals.connect("foto_actualizada", Callable(self, "_on_foto_actualizada"))
    _update_foto()
    cargar_datos_usuario()

# -----------------------
# ACTUALIZAR FOTO
# -----------------------
func _update_foto():
    var foto_nombre = Globals.user.get("foto", "")
    var ruta = "res://imagenes_perfil/%s" % foto_nombre
    if FileAccess.file_exists(ruta):
        var img = Image.new()
        img.load(ruta)
        var tex = ImageTexture.new()
        tex.create_from_image(img)
        foto.texture = tex

# -----------------------
# SELECCIONAR FOTO
# -----------------------
func _on_editar_foto():
    var selector = contenedor_fotos.instantiate()
    add_child(selector)
    selector.connect("foto_seleccionada", Callable(self, "_on_foto_elegida"))

func _on_foto_elegida(nombre_foto: String) -> void:
    var ruta = "res://imagenes_perfil/%s" % nombre_foto
    if not FileAccess.file_exists(ruta):
        push_warning("La imagen seleccionada no existe: %s" % ruta)
        return

    var img = Image.new()
    img.load(ruta)
    var tex = ImageTexture.new()
    tex.create_from_image(img)
    foto.texture = tex

    Globals.user["foto"] = nombre_foto
    Globals.emit_signal("foto_cambiada", nombre_foto)

    # Guardar en Firebase (no bloqueante)
    var auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
    add_child(auth)
    var uid = Globals.user.get("uid", "")
    if uid != "":
        auth.update_user_data(uid, {"foto": nombre_foto}).then(func(res):
            if res.has("error"):
                push_error("Error al guardar la foto en Firebase: %s" % res["error"])
            else:
                print("Foto actualizada correctamente:", nombre_foto)
        )

    # Mostrar notificación correctamente
    await mostrar_notificacion("✅ Foto de perfil actualizada")

    if has_node("perfil_fotos"):
        get_node("perfil_fotos").queue_free()

# -----------------------
# EDITAR NOMBRE
# -----------------------
func _on_ed_nombre_pressed() -> void:
    var selector = contenedor_nombre.instantiate()
    add_child(selector)
    selector.connect("nombre_guardado", Callable(self, "_on_nombre_guardado"))

func _on_nombre_guardado(nuevo_nombre: String) -> void:
    Globals.user["nombre"] = nuevo_nombre
    var auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
    add_child(auth)
    var uid = Globals.user.get("uid", "")
    if uid != "":
        auth.update_user_data(uid, {"nombre": nuevo_nombre})
    mostrar_notificacion("✅ Nombre actualizado")
    cargar_datos_usuario()

# -----------------------
# EDITAR CONTRASEÑA
# -----------------------
func _on_ed_contraseña_pressed() -> void:
    var selector = contenedor_contra.instantiate()
    add_child(selector)
    selector.connect("contraseña_guardada", Callable(self, "_on_contraseña_guardada"))

func _on_contraseña_guardada(nueva_contra: String) -> void:
    password = nueva_contra
    var auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
    add_child(auth)
    var uid = Globals.user.get("uid", "")
    if uid != "":
        auth.update_user_data(uid, {"password": nueva_contra})
    mostrar_notificacion("✅ Contraseña actualizada")

# -----------------------
# CARGAR DATOS USUARIO
# -----------------------
func cargar_datos_usuario():
    var user = Globals.user
    nombre = user.get("nombre", "Usuario sin nombre")
    var foto_id = user.get("foto", "default")
    var ruta = "res://assets/sprites/trophies/%s" % foto_id
    if ResourceLoader.exists(ruta):
        foto.texture = load(ruta)
    else:
        foto.texture = load("res://assets/sprites/ui/Logros/el minino resiste.png")

func _on_foto_actualizada(foto_nueva: String):
    cargar_datos_usuario()

# -----------------------
# CERRAR SESIÓN
# -----------------------
func _on_cerrar_sesion_pressed() -> void:
    Globals.user.clear()
    get_tree().change_scene_to_file("res://escenas/usuario/registro/iniciarSesion.tscn")

# -----------------------
# NOTIFICACIÓN TEMPORAL
# -----------------------
func mostrar_notificacion(texto: String, duracion: float = 2.0) -> void:
    label_notificacion.text = texto
    label_notificacion.visible = true
    await get_tree().create_timer(duracion).timeout
    label_notificacion.visible = false


# -----------------------
# IR A PERFIL
# -----------------------
func _on_perfil_pressed() -> void:
    get_tree().change_scene_to_file("res://escenas/usuario/Perfil/perfil.tscn")
