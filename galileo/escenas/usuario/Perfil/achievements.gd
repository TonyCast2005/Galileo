# achievements.gd
extends Node

# Requisitos: Globals.user debe contener:
# "uid" (string)
# "racha": { "dias": int, "ultima_fecha": "YYYY-MM-DD" }
# "progreso": { "leccion_actual": int, "nivel_actual": "novato" }
# "metrics": donde puedas guardar tiempos/respuestas
# "logros": { ... }  # se actualizará aquí
# "question_history" (opcional) para tiempos por pregunta, seguidas correctas, etc.

var auth = null  # asigna tu instancia de auth/firebase helper antes de usar

func _init(_auth=null):
	auth = _auth

# Llamar desde login: await update_all_achievements()
func update_all_achievements() -> void:
	var uid = Globals.user.get("uid", "")
	if uid == "":
		return

	# aseguramos que exista el dict de logros
	if not Globals.user.has("logros"):
		Globals.user["logros"] = {}

	var changed = false

	changed = changed or check_primera_presa()
	changed = changed or check_caja_carton()
	changed = changed or check_pez_gordo()
	changed = changed or check_experto_arduino()
	changed = changed or check_racha_based()
	changed = changed or check_gato_velocista()
	changed = changed or check_pelea_en_el_techo()
	changed = changed or check_PE_90_metodologia()
	changed = changed or check_aprendiz_veloz()
	changed = changed or check_teorico_nato()
	changed = changed or check_explorador_incanzable()
	changed = changed or check_aprendiz_visual()
	changed = changed or check_cazador_de_bugs()

	if changed:
		# guardar en Globals (ya modificado) y en Firebase
		var actuales = Globals.user["logros"]
		Globals.user["logros"] = actuales
		if auth != null:
			await auth._update_user_data(Globals.user["uid"], { "logros": actuales })
			print("Logros actualizados en Firebase:", actuales)
		else:
			print("Logros actualizados localmente:", actuales)


# -------------------------
# 1. Primera presa
# -------------------------
func check_primera_presa() -> bool:
	if Globals.user["logros"].get("primera_presa", false):
		return false
	# condición: haber completado al menos una lección
	var progreso = Globals.user.get("progreso", {})
	if progreso.get("leccion_actual", 0) > 0:
		Globals.user["logros"]["primera_presa"] = true
		return true
	return false

# -------------------------
# 2. Caja de cartón
# -------------------------
func check_caja_carton() -> bool:
	if Globals.user["logros"].get("caja_carton", false):
		return false
	# condición: completar todas las lecciones de un nivel
	# necesitamos que guardes en Globals.user["progreso"]["completadas_por_nivel"] = { "novato": 10, "competente": 8, ... }
	var completas = Globals.user.get("progreso", {}).get("completadas_por_nivel", {})
	for nivel in completas.keys():
		var completadas = completas[nivel]
		var total_requerido = Globals.user.get("progreso", {}).get("total_por_nivel", {}).get(nivel, 9999)
		if total_requerido != 0 and completadas >= total_requerido:
			Globals.user["logros"]["caja_carton"] = true
			return true
	return false

# -------------------------
# 3. Pez gordo (examen intermedio o superior)
# -------------------------
func check_pez_gordo() -> bool:
	if Globals.user["logros"].get("pez_gordo", false):
		return false
	# condicion: haber aprobado un examen cuyo nivel sea "competente" o "experimentado"
	# asumimos que guardas en Globals.user["metrics"]["examenes"] = [ { "nivel":"competente", "puntaje":85 }, ... ]
	for ex in Globals.user.get("metrics", {}).get("examenes", []):
		var nivel = str(ex.get("nivel", "")).to_lower()
		var aprobado = int(ex.get("puntaje", 0)) >= 60  # ajusta corte si quieres
		if aprobado and (nivel == "competente" or nivel == "experimentado" or nivel == "intermedio"):
			Globals.user["logros"]["pez_gordo"] = true
			return true
	return false

# -------------------------
# 4. Experto en Arduino
# -------------------------
func check_experto_arduino() -> bool:
	if Globals.user["logros"].get("experto_arduino", false):
		return false
	# condición: completar el último nivel del nivel 'experimentado'
	# asumimos Globals.user["progreso"]["nivel_actual"] y un flag "termino_experimentado"
	if Globals.user.get("progreso", {}).get("termino_experimentado", false):
		Globals.user["logros"]["experto_arduino"] = true
		return true
	return false

# -------------------------
# 5-7. Rachas 5/10/20 días
# -------------------------
func check_racha_based() -> bool:
	var racha = Globals.user.get("racha", {})
	var dias = int(racha.get("dias", 0))
	var changed = false
	if dias >= 5 and not Globals.user["logros"].get("minino_resiste", false):
		Globals.user["logros"]["minino_resiste"] = true
		changed = true
	if dias >= 10 and not Globals.user["logros"].get("gato_pwm", false):
		Globals.user["logros"]["gato_pwm"] = true
		changed = true
	if dias >= 20 and not Globals.user["logros"].get("leyenda_cable", false):
		Globals.user["logros"]["leyenda_cable"] = true
		changed = true
	return changed

# -------------------------
# 8. Gato velocista: 5 preguntas < 50% tiempo ideal
# -------------------------
func check_gato_velocista() -> bool:
	if Globals.user["logros"].get("gato_velocista", false):
		return false
	# debes guardar en Globals.user["metrics"]["question_times"] el historial reciente (segundos)
	var times = Globals.user.get("metrics", {}).get("question_times", [])  # array de floats (segundos)
	if times.size() < 5:
		return false
	# Consideramos "tiempo ideal" como promedio histórico; puedes guardar "ideal_time" en metrics
	var ideal = float(Globals.user.get("metrics", {}).get("ideal_time", 10.0))
	var count = 0
	for t in times:
		if float(t) <= ideal * 0.5:
			count += 1
	if count >= 5:
		Globals.user["logros"]["gato_velocista"] = true
		return true
	return false

# -------------------------
# 9. Pelea en el techo: 10 correctas seguidas
# -------------------------
func check_pelea_en_el_techo() -> bool:
	if Globals.user["logros"].get("pelea_en_el_techo", false):
		return false
	# necesitas mantener contador de correctas seguidas: Globals.user["metrics"]["consecutive_correct"]
	var cons = int(Globals.user.get("metrics", {}).get("consecutive_correct", 0))
	if cons >= 10:
		Globals.user["logros"]["pelea_en_el_techo"] = true
		return true
	return false

# -------------------------
# 10. PE >= 90 en una metodología
# -------------------------
func check_PE_90_metodologia() -> bool:
	if Globals.user["logros"].get("de_noche_todos_los_gatos", false):
		return false
	# asumimos que guardas porcentaje por metodologia: Globals.user["metrics"]["PE_by_method"] = { "Significativo": 92, ... }
	var pe_map = Globals.user.get("metrics", {}).get("PE_by_method", {})
	for key in pe_map.keys():
		if float(pe_map[key]) >= 90.0:
			Globals.user["logros"]["de_noche_todos_los_gatos"] = true
			return true
	return false

# -------------------------
# 11. Aprendiz veloz: completar nivel en mitad del tiempo promedio
# -------------------------
func check_aprendiz_veloz() -> bool:
	if Globals.user["logros"].get("aprendiz_veloz", false):
		return false
	# necesitas guardar tiempos por nivel históricamente: Globals.user["metrics"]["level_times"][nivel] = [t1,t2,...]
	var level_times = Globals.user.get("metrics", {}).get("level_times", {})
	for nivel in level_times.keys():
		var arr = level_times[nivel]
		if arr.size() == 0:
			continue
		var avg = 0.0
		for v in arr: avg += float(v)
		avg = avg / float(arr.size())
		# si el último tiempo fue <= avg/2
		var last_time = float(arr[arr.size()-1])
		if last_time <= avg * 0.5:
			Globals.user["logros"]["aprendiz_veloz"] = true
			return true
	return false

# -------------------------
# 12. Teórico nato: 20 aciertos en modo Significativo
# -------------------------
func check_teorico_nato() -> bool:
	if Globals.user["logros"].get("teorico_nato", false):
		return false
	var correct_sign = int(Globals.user.get("metrics", {}).get("correct_significativo", 0))
	if correct_sign >= 20:
		Globals.user["logros"]["teorico_nato"] = true
		return true
	return false

# -------------------------
# 13. Explorador incanzable: 15 ejercicios Descubrimiento Guiado
# -------------------------
func check_explorador_incanzable() -> bool:
	if Globals.user["logros"].get("explorador_incanzable", false):
		return false
	var solved = int(Globals.user.get("metrics", {}).get("solved_descubrimiento", 0))
	if solved >= 15:
		Globals.user["logros"]["explorador_incanzable"] = true
		return true
	return false

# -------------------------
# 14. Aprendiz visual: 10 ejercicios ABE
# -------------------------
func check_aprendiz_visual() -> bool:
	if Globals.user["logros"].get("aprendiz_visual", false):
		return false
	var solved = int(Globals.user.get("metrics", {}).get("solved_abe", 0))
	if solved >= 10:
		Globals.user["logros"]["aprendiz_visual"] = true
		return true
	return false

# -------------------------
# 15. Cazador de Bugs: 10 correcciones
# -------------------------
func check_cazador_de_bugs() -> bool:
	if Globals.user["logros"].get("cazador_de_bugs", false):
		return false
	var fixed = int(Globals.user.get("metrics", {}).get("bug_fixes", 0))
	if fixed >= 10:
		Globals.user["logros"]["cazador_de_bugs"] = true
		return true
	return false
