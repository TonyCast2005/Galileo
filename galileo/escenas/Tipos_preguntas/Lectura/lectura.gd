extends Control

@onready var Titulo = $TituloLectura
@onready var NombreLeccion = $NombreLección
@onready var lectura = $ScrollContainer/textoLectura
@onready var http = $HTTPRequest

var leccion_id = "arduino_basico"  # Se puede cambiar desde otra escena

func _ready():
    cargar_leccion()
 


# ======================================
# 🔹 Cargar la PISTA desde Globals
# ======================================



# ======================================
# 🔹 Pedir datos de Firebase
# ======================================
func cargar_leccion():
    var url = "https://galileo-af640-default-rtdb.firebaseio.com/lecturas/%s.json" % leccion_id
    http.request(url)


# ======================================
# 🔹 Procesar respuesta de Firebase
# ======================================
func _on_request_completed(result, response_code, headers, body):
    if response_code != 200:
        NombreLeccion.text = "❌ Error al cargar"
        lectura.text = ""
        return

    var data = JSON.parse_string(body.get_string_from_utf8())
    if typeof(data) != TYPE_DICTIONARY:
        NombreLeccion.text = "⚠️ Lectura inválida"
        return

    NombreLeccion.text = data.get("titulo", "Sin título")
    lectura.text = data.get("contenido", "")
    print("📘 Lectura cargada:", data)


# ======================================
# 🔹 Botón continuar
# ======================================
func _on_continuar_pressed():
    get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")


# ======================================
# 🔹 AYUDA (gato hablando)
# ======================================
func _on_ayuda_pressed():
    var escena_gato = preload("res://escenas/Pistas/Pistas_Contenedor.tscn").instantiate()
    add_child(escena_gato)
    escena_gato.set_pista(Globals.pista_lectura)
