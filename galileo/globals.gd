extends Node

# -----------------------------
#   SEÑALES
# -----------------------------
signal foto_actualizada(foto_nueva)
signal datos_cargados_correctamente(uid)

# Variables de estado
var desbloquear_pendiente: bool = false
var niveles_desbloqueados: int = 1     

# Progreso de temas (4 niveles cada uno)
var desbloqueados1 = [true, false, false, false]
var desbloqueados2 = [true, false, false, false]
var desbloqueados3 = [true, false, false, false]
var desbloqueados4 = [true, false, false, false]

# Candados grandes
var desbloquear2: bool = false
var desbloquear3: bool = false
var desbloquear4: bool = false
var desbloquear5: bool = false # Examen

var repetir_bloque = false
var bloque_actual = 0

# -----------------------------
#   VARIABLES GLOBALES
# -----------------------------
var firebase_auth
var user_uid = ""
var email = ""
var nombre = ""
var nivel = ""
var foto = ""

var user_data = {}
var progreso = {}
var racha = {}
var logros = {}

var resultado_examen = {}
var temp_preview_data = {}

# -----------------------------
#   INICIALIZACIÓN
# -----------------------------
func _ready():
    firebase_auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()

# ============================================================
#   FUNCIONES DE DESBLOQUEO DE PROGRESO
# ============================================================
func _get_topic_unlock_array(tema_indice: int) -> Array:
    match tema_indice:
        0: return desbloqueados1
        1: return desbloqueados2
        2: return desbloqueados3
        3: return desbloqueados4
        _: return []

func is_tema_desbloqueado(tema_indice: int) -> bool:
    if tema_indice == 0:
        return true
    
    if tema_indice == 4:
        return desbloquear5

    var tema_anterior_indice = tema_indice - 1
    var tema_anterior_array = _get_topic_unlock_array(tema_anterior_indice)

    if not tema_anterior_array is Array or tema_anterior_array.is_empty():
        return false 

    for u in tema_anterior_array:
        if not u:
            return false

    return true

func desbloquear_siguiente_nivel(tema_indice: int, nivel_indice: int) -> void:
    var tema_array = _get_topic_unlock_array(tema_indice)
    var siguiente_nivel = nivel_indice + 1
    var tema_completado = false

    if siguiente_nivel < tema_array.size():
        if !tema_array[siguiente_nivel]:
            tema_array[siguiente_nivel] = true
            guardar_progreso()
    elif siguiente_nivel == tema_array.size():
        tema_completado = true

    if tema_completado:
        var siguiente_tema_indice = tema_indice + 1
        var siguiente_tema_array = _get_topic_unlock_array(siguiente_tema_indice)

        if siguiente_tema_array is Array and siguiente_tema_array.size() > 0:
            if !siguiente_tema_array[0]:
                siguiente_tema_array[0] = true
                guardar_progreso()
        elif siguiente_tema_indice == 4:
            if !desbloquear5:
                desbloquear5 = true
                guardar_progreso()

# ============================================================
#   HELPER PARA CARGA SEGURA DE ARRAYS
# ============================================================
func _safe_load_array(progreso_dict: Dictionary, key: String, default_array: Array) -> Array:
    var loaded = progreso_dict.get(key, default_array)
    return loaded if loaded is Array else default_array

# ============================================================
#   CARGAR DATOS DE USUARIO
# ============================================================
func cargar_datos_usuario(uid: String) -> void:
    user_uid = uid
    firebase_auth._get_user_data(uid, self, "_on_datos_usuario_recibidos")

func _on_datos_usuario_recibidos(res: Dictionary) -> void:
    if not res.has("data"):
        push_error("Error al cargar datos del usuario.")
        return

    var doc = res.data
    user_data = doc

    email = doc.get("email", "")
    nombre = doc.get("nombre", "")
    nivel = doc.get("nivel", "")
    foto = doc.get("foto", "default")

    progreso = doc.get("progreso", {})

    desbloqueados1 = _safe_load_array(progreso, "desbloqueados1", desbloqueados1)
    desbloqueados2 = _safe_load_array(progreso, "desbloqueados2", desbloqueados2)
    desbloqueados3 = _safe_load_array(progreso, "desbloqueados3", desbloqueados3)
    desbloqueados4 = _safe_load_array(progreso, "desbloqueados4", desbloqueados4)

    desbloquear5 = progreso.get("desbloquear5", desbloquear5)

    racha = doc.get("racha", {"dias": 0, "ultima_fecha": ""})
    logros = doc.get("logros", {})

    emit_signal("foto_actualizada", foto)
    emit_signal("datos_cargados_correctamente", user_uid)

# ============================================================
#   FOTO DE PERFIL
# ============================================================
func actualizar_foto(nueva_foto: String) -> void:
    foto = nueva_foto
    var data = {"foto": nueva_foto}
    firebase_auth.update_user_data(user_uid, data, self, "_on_foto_actualizada")

func _on_foto_actualizada(_res):
    emit_signal("foto_actualizada", foto)

# ============================================================
#   GUARDAR PROGRESO / RACHA / LOGROS
# ============================================================
func guardar_progreso():
    var progreso_a_guardar = {
        "desbloqueados1": desbloqueados1,
        "desbloqueados2": desbloqueados2,
        "desbloqueados3": desbloqueados3,
        "desbloqueados4": desbloqueados4,
        "desbloquear5": desbloquear5,
    }
    var data = {"progreso": progreso_a_guardar}
    firebase_auth.update_user_data(user_uid, data)

func guardar_racha():
    var data = {"racha": racha}
    firebase_auth.update_user_data(user_uid, data)

func guardar_logros():
    var data = {"logros": logros}
    firebase_auth.update_user_data(user_uid, data)

# ============================================================
#   DESBLOQUEO AUTOMÁTICO DE LOGROS
# ============================================================
func desbloquear_logro(clave: String) -> void:
    if not logros.has(clave):
        logros[clave] = true
        guardar_logros()

# ============================================================
#   SISTEMA DE RACHAS
# ============================================================
func actualizar_racha():
    if racha.is_empty():
        racha = {"dias": 0, "ultima_fecha": ""}

    var hoy = _fecha_actual()

    if racha.ultima_fecha == "":
        racha.ultima_fecha = hoy
        racha.dias = 1
        guardar_racha()
        return

    if racha.ultima_fecha == hoy:
        return

    var diff = _dias_de_diferencia(
        parse_date(racha.ultima_fecha),
        Time.get_date_dict_from_system()
    )

    if diff == 1:
        racha.dias += 1
        racha.ultima_fecha = hoy
        guardar_racha()
        _verificar_logros_racha()
    else:
        racha.dias = 1
        racha.ultima_fecha = hoy
        guardar_racha()

func _fecha_actual() -> String:
    var t = Time.get_date_dict_from_system()
    return "%s-%02d-%02d" % [t.year, t.month, t.day]

func _dias_de_diferencia(f1: Dictionary, f2: Dictionary) -> int:
    var t1 = Time.get_unix_time_from_datetime_dict(f1)
    var t2 = Time.get_unix_time_from_datetime_dict(f2)
    return int((t2 - t1) / 86400)

func _verificar_logros_racha():
    if racha.dias == 3:
        desbloquear_logro("racha_3_dias")
    elif racha.dias == 7:
        desbloquear_logro("racha_7_dias")
    elif racha.dias == 30:
        desbloquear_logro("racha_30_dias")

func parse_date(text: String) -> Dictionary:
    if text == "" or not text.contains("-"):
        return {}
    var p = text.split("-")
    return {
        "year": p[0].to_int(),
        "month": p[1].to_int(),
        "day": p[2].to_int()
    }
