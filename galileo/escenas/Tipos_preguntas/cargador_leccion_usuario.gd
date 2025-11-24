extends Node

var firebase
var ejercicios_ids: Array = []
var ejercicios_data: Array = []
var indice_actual := 0

var tema_id := ""
var leccion_id := ""

signal ejercicio_cargado(data)

func _ready():
	firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(firebase)

# ============================================================
#   CARGAR LECCIÓN DEL USUARIO
# ============================================================
func iniciar_leccion(tema:String, leccion:String):
	tema_id = tema
	leccion_id = leccion

	print("📘 Cargando lección:", tema, leccion)

	await cargar_ids_ejercicios()
	await cargar_datos_ejercicios()

	indice_actual = 0
	cargar_siguiente_ejercicio()

# ============================================================
#   CARGAR LOS 4 IDs DE EJERCICIOS
# ============================================================
func cargar_ids_ejercicios():
	var url = "%s/temas/%s/lecciones/%s/ejercicios_asignados.json" % [
		firebase.DB_URL, tema_id, leccion_id
	]

	var req := HTTPRequest.new()
	add_child(req)

	await req.request(url)

	var data = JSON.parse_string(req.get_body_as_string())

	req.queue_free()

	if typeof(data) != TYPE_ARRAY:
		print("❌ No se pudieron obtener los ejercicios")
		return

	ejercicios_ids = data
	print("📌 IDs cargados:", ejercicios_ids)

# ============================================================
#   CARGAR LOS DATOS DE CADA EJERCICIO
# ============================================================
func cargar_datos_ejercicios():
	ejercicios_data.clear()

	for id in ejercicios_ids:
		var dato = await cargar_un_ejercicio(id)
		if dato != null:
			ejercicios_data.append(dato)

	print("📚 Banco final cargado:", ejercicios_data.size())


func cargar_un_ejercicio(id:String) -> Variant:
	var url = "%s/preguntas/%s.json" % [firebase.DB_URL, id]

	var req := HTTPRequest.new()
	add_child(req)

	await req.request(url)
	var data = JSON.parse_string(req.get_body_as_string())
	req.queue_free()

	if typeof(data) != TYPE_DICTIONARY:
		return null

	data["id"] = id
	return data

# ============================================================
#   MOSTRAR EJERCICIO ACTUAL
# ============================================================
func cargar_siguiente_ejercicio():
	if indice_actual >= ejercicios_data.size():
		print("🎉 Lección terminada")
		marcar_leccion_completada()
		return

	var ejercicio = ejercicios_data[indice_actual]
	print("📘 Mostrando ejercicio:", ejercicio["id"])

	emit_signal("ejercicio_cargado", ejercicio)

# ============================================================
#   LLAMAR CUANDO EL USUARIO TERMINE UN EJERCICIO
# ============================================================
func completar_ejercicio():
	indice_actual += 1
	cargar_siguiente_ejercicio()

# ============================================================
#   MARCAR LECCIÓN COMPLETADA EN FIREBASE
# ============================================================
func marcar_leccion_completada():
	var url = "%s/temas/%s/lecciones/%s/completado.json" % [
		firebase.DB_URL, tema_id, leccion_id
	]

	var req := HTTPRequest.new()
	add_child(req)

	await req.request(url, [], HTTPClient.METHOD_PUT, "true")
	req.queue_free()

	print("Lección marcada como completada")
