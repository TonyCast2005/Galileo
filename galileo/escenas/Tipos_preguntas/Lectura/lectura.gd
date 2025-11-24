extends Control

@onready var NombreLeccion = $NombreLección
@onready var TituloTeoria = $TextoTeoria
@onready var TextoLectura = $ScrollContainer/textoLectura

var firebase := Firebase.Database
var id_lectura : int = 1     # <---- Cambia este valor según la lectura que quieras cargar


func _ready() -> void:
    cargar_lectura(id_lectura)


func cargar_lectura(id: int) -> void:
    var ruta = "lecturas/" + str(id)

    firebase.get_value(ruta, self, "_on_lectura_recibida")


func _on_lectura_recibida(result: Dictionary) -> void:
    if result.has("error") and result.error != 0:
        push_error("Error al leer Firebase: " + str(result.error))
        return

    var data = result.value

    # Rellenar UI
    NombreLeccion.text = data.get("nombre", "Sin nombre")
    TituloTeoria.text = data.get("titulo", "Sin título")
    TextoLectura.text = data.get("contenido", "Sin contenido")


func _on_continuar_pressed() -> void:
    # Lógica para pasar al siguiente ejercicio
    pass


func _on_ayuda_pressed() -> void:
    # Mostrar popup
    pass
