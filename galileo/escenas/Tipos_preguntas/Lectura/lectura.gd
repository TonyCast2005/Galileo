extends Control

@onready var Texto = $TextoPregunta
@onready var NombreLeccion = $NombreLección
@onready var lectura = $ScrollContainer/textoLectura
@onready var http = $HTTPRequest   # Debe existir un nodo HTTPRequest

var leccion_id = "arduino_basico"   # 🔹 Aquí pones la lección a cargar


   


func _on_request_completed(result, response_code, headers, body):
    if response_code != 200:
        NombreLeccion.text = "❌ Error al cargar lección"
        lectura.text = ""
        Texto.text = ""
        return

    var data = JSON.parse_string(body.get_string_from_utf8())
    if typeof(data) != TYPE_DICTIONARY:
        NombreLeccion.text = "⚠️ Lección inválida"
        return

    # ==============================
    # Cargar datos en los labels
    # ==============================
    NombreLeccion.text = data.get("titulo", "Sin título")
    lectura.text = data.get("contenido", "")
    Texto.text = data.get("pregunta", "")
    print("📘 Lección cargada correctamente:", data)




func _on_continuar_pressed():
    var nivel_actual = Globals.get("nivel_actual")
    if nivel_actual == null:
        nivel_actual = 1

    var nivel_desbloqueado = Globals.get("nivel_desbloqueado")

    if nivel_actual >= nivel_desbloqueado:
        Globals.set("nivel_desbloqueado", nivel_actual + 1)

    get_tree().change_scene_to_file("res://escenas/usuario/MenuInicial/MenuInicial.tscn")



func _on_ayuda_pressed() -> void:
    # Aquí puedes mostrar pop-ups, textos o ayudas del tema
    print("🔍 Mostrando ayuda...")
