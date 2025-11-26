extends Node

# -----------------------------
# 	SEÑALES
# -----------------------------
signal foto_actualizada(foto_nueva)
signal datos_cargados_correctamente(uid)

var desbloquear_pendiente: bool = false
var niveles_desbloqueados: int = 1 	

# Arrays de estado de los bloques
var desbloqueados1 = [true, false, false, false] # Tema 1: Arduino (4 niveles)
var desbloqueados2 = [false, false, false, false] # Tema 2: Electrónica (4 niveles)
var desbloqueados3 = [false, false, false, false] # Tema 3: Programación (4 niveles)
var desbloqueados4 = [false, false, false, false] # Tema 4: Entradas Digitales (4 niveles)

# 💡 Eliminamos variables redundantes (el estado se deriva de los arrays)
# var desbloquear2: bool = false 
# var desbloquear3: bool = false
# var desbloquear4: bool = false
var desbloquear5: bool = false # Examen (se mantiene porque no es un array)


var repetir_bloque = false
var bloque_actual = 0

# -----------------------------
# 	VARIABLES GLOBALES
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
# 	INICIALIZACIÓN
# -----------------------------
func _ready():
    firebase_auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()

# ============================================================
# 	FUNCIONES DE DESBLOQUEO DE PROGRESO
# ============================================================

# Función auxiliar para obtener el array de desbloqueos por índice de tema
func _get_topic_unlock_array(tema_indice: int) -> Array:
    match tema_indice:
        0: return desbloqueados1
        1: return desbloqueados2
        2: return desbloqueados3
        3: return desbloqueados4
        _: return []

# Función para verificar si un tema completo está desbloqueado para la IU principal.
# (Se usa en MenuInicial.gd para el candado grande)
func is_tema_desbloqueado(tema_indice: int) -> bool:
    # Tema 1 (índice 0) siempre está desbloqueado
    if tema_indice == 0:
        return true
    
    # Examen (índice 4)
    if tema_indice == 4:
        return desbloquear5
        
    # Un tema N está desbloqueado si el Tema N-1 está 100% completo
    var tema_anterior_indice = tema_indice - 1
    var tema_anterior_array = _get_topic_unlock_array(tema_anterior_indice)
    
    # Si el tema anterior no existe (error de índice), asumimos falso
    if tema_anterior_array.is_empty():
        return false 
        
    for is_unlocked in tema_anterior_array:
        if not is_unlocked:
            return false # Si un solo bloque no está completo, el tema siguiente sigue bloqueado
    
    return true # Todos los bloques del tema anterior están completos


# Función principal a llamar cuando un nivel se completa
# (tema_indice va de 0 a 3, nivel_indice va de 0 a 3)
func desbloquear_siguiente_nivel(tema_indice: int, nivel_indice: int) -> void:
    # Intentar desbloquear el siguiente nivel dentro del mismo tema
    var tema_array = _get_topic_unlock_array(tema_indice)
    var siguiente_nivel = nivel_indice + 1
    var tema_completado = false

    if siguiente_nivel < tema_array.size():
        # Desbloquear el siguiente nivel en el mismo tema
        if !tema_array[siguiente_nivel]:
            tema_array[siguiente_nivel] = true
            print("Nivel desbloqueado: Tema ", tema_indice + 1, ", Nivel ", siguiente_nivel + 1)
            # 💡 Guardar inmediatamente el progreso en Firebase
            guardar_progreso()
            
    elif siguiente_nivel == tema_array.size():
        # Es el último nivel del tema actual, pasar al siguiente
        tema_completado = true
        
    # Si el tema se completó, desbloquear el primer nivel del siguiente tema
    if tema_completado:
        var siguiente_tema_indice = tema_indice + 1
        var siguiente_tema_array = _get_topic_unlock_array(siguiente_tema_indice)

        if siguiente_tema_array.size() > 0:
            # Desbloquear el primer nivel del siguiente tema
            if !siguiente_tema_array[0]:
                siguiente_tema_array[0] = true
                print("Tema desbloqueado: Tema ", siguiente_tema_indice + 1, " (Nivel 1)")
                # 💡 Guardar inmediatamente el progreso en Firebase
                guardar_progreso()
                
        elif siguiente_tema_indice == 4:
            # El índice 4 corresponde al Examen
            if !desbloquear5:
                desbloquear5 = true
                print("¡Examen final desbloqueado!")
                # 💡 Guardar inmediatamente el progreso en Firebase
                guardar_progreso()


# ============================================================
# 	FUNCIÓN PRINCIPAL: CARGAR USUARIO
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

    # Extraer y CARGAR progreso (¡AQUÍ ESTABA LA CLAVE!)
    progreso = doc.get("progreso", {})
    
    # 💡 Cargar los arrays guardados en las variables de sesión
    # Si la clave existe en Firestore, úsala; si no, mantén el valor inicial
    desbloqueados1 = progreso.get("desbloqueados1", desbloqueados1)
    desbloqueados2 = progreso.get("desbloqueados2", desbloqueados2)
    desbloqueados3 = progreso.get("desbloqueados3", desbloqueados3)
    desbloqueados4 = progreso.get("desbloqueados4", desbloqueados4)
    desbloquear5 = progreso.get("desbloquear5", desbloquear5)
    
    # Extraer racha
    racha = doc.get("racha", {})
    
    # Extraer logros
    logros = doc.get("logros", {})

    emit_signal("foto_actualizada", foto)
    emit_signal("datos_cargados_correctamente", user_uid)

# ============================================================
# 	ACTUALIZAR FOTO DEL PERFIL
# ============================================================
func actualizar_foto(nueva_foto: String) -> void:
    foto = nueva_foto

    var ruta = "usuarios/%s" % user_uid
    var data = {"foto": nueva_foto}

    firebase_auth.update_document(ruta, data, self, "_on_foto_actualizada")

func _on_foto_actualizada(result):
    emit_signal("foto_actualizada", foto)

# ============================================================
# 	GUARDAR PROGRESO / RACHA / LOGROS
# ============================================================
func guardar_progreso():
    var ruta = "usuarios/%s" % user_uid
    # 💡 Construir el diccionario de progreso para guardar (CON TODOS LOS ARRAYS)
    var progreso_a_guardar = {
        "desbloqueados1": desbloqueados1,
        "desbloqueados2": desbloqueados2,
        "desbloqueados3": desbloqueados3,
        "desbloqueados4": desbloqueados4,
        "desbloquear5": desbloquear5,
    }
    var data = {"progreso": progreso_a_guardar}

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
# 	FUNCIÓN PARA DESBLOQUEAR UN LOGRO AUTOMÁTICAMENTE
# ============================================================
func desbloquear_logro(clave: String) -> void:
    if not logros.has(clave):
        logros[clave] = true
        guardar_logros()
        print("¡Logro desbloqueado!: ", clave)

# ============================================================
# 	SISTEMA AUTOMÁTICO DE RACHAS
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
# 	FECHA HOY EN FORMATO YYYY-MM-DD
# ------------------------------------------------------------
func _fecha_actual() -> String:
    var t = Time.get_date_dict_from_system()
    return "%s-%02d-%02d" % [t.year, t.month, t.day]

# ------------------------------------------------------------
# 	DIFERENCIA DE DÍAS ENTRE DOS FECHAS (dict date)
# ------------------------------------------------------------
func _dias_de_diferencia(f1: Dictionary, f2: Dictionary) -> int:
    var t1 = Time.get_unix_time_from_datetime_dict(f1)
    var t2 = Time.get_unix_time_from_datetime_dict(f2)
    return int((t2 - t1) / 86400) 	# 86400 = segundos de un día	

# ------------------------------------------------------------
# 	DESBLOQUEAR LOGROS AUTOMÁTICOS DE RACHAS
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
