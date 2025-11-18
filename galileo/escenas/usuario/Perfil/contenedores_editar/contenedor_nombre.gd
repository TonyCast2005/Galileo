extends Control

signal nombre_actualizado(nuevo_nombre)

@onready var input_nombre = $Ventana/Nuevo
@onready var actual = $Ventana/Actual
@onready var Guardar = $Ventana/Guardar

func _ready():
    cargar_datos_usuario()

func cargar_datos_usuario():
    var user = Globals.user
    actual.text = user.get("nombre", "Usuario sin nombre")

func _on_guardar_pressed():
    var nuevo_nombre = input_nombre.text.strip_edges()
    print("🔥 BOTÓN GUARDAR PRESIONADO")

    if nuevo_nombre == "":
        push_warning("El nombre no puede estar vacío")
        return

    # Actualizar Globals
    Globals.user["nombre"] = nuevo_nombre
    Globals.emit_signal("nombre_actualizado", nuevo_nombre)

    # Guardar en Firebase
    var auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
    add_child(auth)

    var uid = Globals.user["uid"]
    var res = await auth.update_user_data(uid, {"nombre": nuevo_nombre})

    if res.has("error"):
        push_error("Error al guardar el nombre: %s" % res["error"])
    else:
        print("Nombre actualizado correctamente:", nuevo_nombre)

    queue_free()

func _on_salir_pressed() -> void:
    queue_free()
