extends Node

var desbloquear = false
var bloque_actual = 0



# 🌟 NUEVO: Diccionario para guardar el progreso de todos los temas.
# La llave es el nombre del tema y el valor es el número de botones desbloqueados.
var theme_progress = {
    "Arduino": 2, # Ejemplo: Inicia con 2 botones desbloqueados (0 y 1)
    "Electronica": 2, 
    "Programacion": 2,
    "Entradas": 2,
    # Añade aquí las llaves para tus otros 4 temas
}
# -----------------------------
#        SEÑALES
# -----------------------------
signal foto_actualizada(foto_nueva)
signal datos_cargados_correctamente(uid)

var desbloquear_pendiente = false # Lo usarás para saber si debe desbloquear en el menú
var examen_aprobado = false
var niveles_desbloqueados: int = 1  

var repetir_bloque = false

# -----------------------------
#    VARIABLES GLOBALES
# -----------------------------
var firebase_auth
var user : Dictionary = {}

var user_uid = ""
var email = ""
var nombre = ""
var nivel = ""
var foto = ""

# Datos completos de Firebase
var user_data = {}  
var progreso = {}
var racha = {}
var logros = {}

var resultado_examen = {}
var temp_preview_data = {}

# -----------------------------
#     INICIALIZACIÓN
# -----------------------------
func _ready():
    firebase_auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()


# ============================================================
#               FUNCIÓN PRINCIPAL: CARGAR USUARIO
# ============================================================
func cargar_datos_usuario(uid: String) -> void:
    user_uid = uid

    var ruta = "usuarios/%s" % uid

    firebase_auth.get_document(ruta, self, "_on_datos_usuario_recibidos")


# Callback cuando Firebase responde
func _on_datos_usuario_recibidos(res: Dictionary) -> void:
    if not res.has("document"):
        push_error("Error al cargar datos del usuario")
        return

    var doc = firebase_auth.parse_document(res.document)

    # Guardar todo el documento completo
    user_data = doc

    # Extraer datos principales
    email = doc.get("email", "")
    nombre = doc.get("nombre", "")
    nivel = doc.get("nivel", "")
    foto = doc.get("foto", "default")

    # Extraer progreso
    progreso = doc.get("progreso", {})
    
    # Extraer racha
    racha = doc.get("racha", {})
    
    # Extraer logros
    logros = doc.get("logros", {})

    emit_signal("foto_actualizada", foto)
    emit_signal("datos_cargados_correctamente", user_uid)

# ============================================================
#                  ACTUALIZAR FOTO DEL PERFIL
# ============================================================
func actualizar_foto(nueva_foto: String) -> void:
    foto = nueva_foto

    var ruta = "usuarios/%s" % user_uid
    var data = {"foto": nueva_foto}

    firebase_auth.update_document(ruta, data, self, "_on_foto_actualizada")


func _on_foto_actualizada(result):
    emit_signal("foto_actualizada", foto)

# ============================================================
#              GUARDAR PROGRESO / RACHA / LOGROS
# ============================================================
func guardar_progreso():
    var ruta = "usuarios/%s" % user_uid
    var data = {"progreso": progreso}

    firebase_auth.update_document(ruta, data)

func guardar_racha():
    var ruta = "usuarios/%s" % user_uid
    var data = {"racha": racha}

    firebase_auth.update_document(ruta, data)

func guardar_logros():
    var ruta = "usuarios/%s" % user_uid
    var data = {"logros": logros}

    firebase_auth.update_document(ruta, data)

# ============================================================
#     FUNCIÓN PARA DESBLOQUEAR UN LOGRO AUTOMÁTICAMENTE
# ============================================================
func desbloquear_logro(clave: String) -> void:
    if not logros.has(clave):
        logros[clave] = true
        guardar_logros()
        print("¡Logro desbloqueado!: ", clave)

# ============================================================
#                 SISTEMA AUTOMÁTICO DE RACHAS
# ============================================================

func actualizar_racha():
    if racha.is_empty():
        racha = {"dias": 0, "ultima_fecha": ""}

    var fecha_hoy = _fecha_actual()

    # Primera vez entrando
    if racha.ultima_fecha == "":
        racha.ultima_fecha = fecha_hoy
        racha.dias = 1
        guardar_racha()
        return

    # Si ya había entrado hoy → no hacer nada
    if racha.ultima_fecha == fecha_hoy:
        return

    # Convertimos fechas a objetos Date para compararlas
    var date_ultima = parse_date(racha.ultima_fecha)
    var date_hoy = Time.get_date_dict_from_system()
    var diff = _dias_de_diferencia(date_ultima, date_hoy)

    if diff == 1:
        # Día consecutivo → sumar racha
        racha.dias += 1
        racha.ultima_fecha = fecha_hoy
        guardar_racha()

        # Desbloquear logros si quieres
        _verificar_logros_racha()

    else:
        # Más de 1 día sin entrar → reiniciar racha
        racha.dias = 1
        racha.ultima_fecha = fecha_hoy
        guardar_racha()

# ------------------------------------------------------------
#           FECHA HOY EN FORMATO YYYY-MM-DD
# ------------------------------------------------------------
func _fecha_actual() -> String:
    var t = Time.get_date_dict_from_system()
    return "%s-%02d-%02d" % [t.year, t.month, t.day]

# ------------------------------------------------------------
#     DIFERENCIA DE DÍAS ENTRE DOS FECHAS (dict date)
# ------------------------------------------------------------
func _dias_de_diferencia(f1: Dictionary, f2: Dictionary) -> int:
    var t1 = Time.get_unix_time_from_datetime_dict(f1)
    var t2 = Time.get_unix_time_from_datetime_dict(f2)
    return int((t2 - t1) / 86400)   # 86400 = segundos de un día	

# ------------------------------------------------------------
#   DESBLOQUEAR LOGROS AUTOMÁTICOS DE RACHAS
# ------------------------------------------------------------
func _verificar_logros_racha():
    if racha.dias == 3:
        desbloquear_logro("racha_3_dias")
    elif racha.dias == 7:
        desbloquear_logro("racha_7_dias")
    elif racha.dias == 30:
        desbloquear_logro("racha_30_dias")

func parse_date(fecha_texto: String) -> Dictionary:
    if fecha_texto == "" or not fecha_texto.contains("-"):
        return {}

    var partes = fecha_texto.split("-")
    if partes.size() != 3:
        return {}

    return {
        "year": partes[0].to_int(),
        "month": partes[1].to_int(),
        "day": partes[2].to_int()
    }

func parse_fecha(fecha_str: String) -> Dictionary:
    var partes = fecha_str.split("-")
    return {
        "year": partes[0].to_int(),
        "month": partes[1].to_int(),
        "day": partes[2].to_int()
    }
    
   
