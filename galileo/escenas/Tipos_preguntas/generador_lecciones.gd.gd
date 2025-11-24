extends Node

var firebase

func _ready():
	firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(firebase)
  
# ===========================================================
#   GENERAR LECCIÓN COMPLETA
#   tema_id      → ej. "introduccion_arduino"
#   leccion_id   → ej. "l1", "l2", "l3", "l4"
# ============================================================
func generar_leccion(tema_id: String, leccion_id: String) -> void:
	print("🔍 Generando lección:", tema_id, leccion_id)

	# 1️⃣ Obtener banco completo del tema
	var banco = await cargar_banco_tema(tema_id)
	if banco.is_empty():
		print("❌ No hay ejercicios en este tema:", tema_id)
		return

	# 2️⃣ Obtener ejercicios usados en lecciones anteriores
	var usados = await cargar_ejercicios_usados(tema_id, leccion_id)

	# 3️⃣ Filtrar el banco
	var disponibles = []
	for e in banco:
		if not usados.has(e["id"]):
			disponibles.append(e)

	if disponibles.size() < 4:
		print("❌ No hay suficientes ejercicios nuevos para esta lección")
		return

	# 4️⃣ Seleccionar 4 aleatorios
	disponibles.shuffle()
	var seleccionados = []
	for i in range(4):
		seleccionados.append(disponibles[i]["id"])

	print("📌 Selección final:", seleccionados)

	# 5️⃣ Guardar en Firebase
	await guardar_leccion(tema_id, leccion_id, seleccionados)

	print("✅ Lección generada con éxito:", leccion_id)

# ============================================================
#   CARGAR BANCO DE EJERCICIOS POR TEMA
# ============================================================
func cargar_banco_tema(tema_id: String) -> Array:
	var url = "%s/preguntas_abiertas.json" % firebase.DB_URL

	var req := HTTPRequest.new()
	add_child(req)

	await req.request(url)
	var result = JSON.parse_string(req.get_body_as_string())

	req.queue_free()

	if result == null:
		return []

	var lista = []

	for id in result.keys():
		var p = result[id]
		if p.has("tema") and p["tema"] == tema_id:
			p["id"] = id
			lista.append(p)

	print("📚 Banco cargado:", lista.size(), "ejercicios")
	return lista

# ============================================================
#   CARGAR EJERCICIOS USADOS EN LECCIONES PASADAS
# ============================================================
func cargar_ejercicios_usados(tema_id: String, leccion_id: String) -> Array:
	var url = "%s/temas/%s/lecciones.json" % [firebase.DB_URL, tema_id]

	var req := HTTPRequest.new()
	add_child(req)

	await req.request(url)
	var result = JSON.parse_string(req.get_body_as_string())

	req.queue_free()

	if result == null:
		return []

	var usados = []

	for lid in result.keys():
		if lid == leccion_id:
			continue
		if result[lid].has("ejercicios_asignados"):
			usados += result[lid]["ejercicios_asignados"]

	print("📌 Ejercicios usados:", usados)
	return usados

# ============================================================
#   GUARDAR LA LECCIÓN CON SUS EJERCICIOS
# ============================================================
func guardar_leccion(tema_id: String, leccion_id: String, lista: Array) -> void:
	var url = "%s/temas/%s/lecciones/%s.json" % [
		firebase.DB_URL,
		tema_id,
		leccion_id
	]

	var data = {
		"ejercicios_asignados": lista,
		"completado": false
	}

	var req := HTTPRequest.new()
	add_child(req)

	var headers = ["Content-Type: application/json"]

	await req.request(url, headers, HTTPClient.METHOD_PUT, JSON.stringify(data))
	req.queue_free()

	print("Lección guardada correctamente en Firebase")
