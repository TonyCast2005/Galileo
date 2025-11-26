extends Node

# --------------------------------------------------------------------------
# 🌟 SEGUIMIENTO DETALLADO PARA LAS 3 METODOLOGÍAS 🌟
# ESTOS SON LOS DATOS CLAVE para la DIFICULTAD ADAPTATIVA
# Se deben guardar en la Base de Datos (Firestore).
var methodology_tracking = {
    "Significativo": {"correct": 0, "attempts": 0, "score": 1.0},
    "Descubrimiento": {"correct": 0, "attempts": 0, "score": 1.0},
    "ABE": {"correct": 0, "attempts": 0, "score": 1.0},
}


# --------------------------------------------------------------------------
# CONSTANTES DE MAPEO Y LÓGICA DE NEGOCIO
# --------------------------------------------------------------------------

# Mapeo de Ejercicio (5 tipos) a Metodología (3 tipos)
const EXERCISE_TO_METHODOLOGY = {
    "PA": "ABE",
    "OM1": "ABE",
    "VF": "Descubrimiento",
    "SA": "Descubrimiento",
    "PE": "Significativo",
}

# Mapeo de Metodología a Tipo de Ejercicio Preferido para refuerzo
const METHODOLOGY_EXERCISES = {
    "ABE": "OM1",
    "Significativo": "PE",
    "Descubrimiento": "VF",
}


# --------------------------------------------------------------------------
# FUNCIONALIDAD CLAVE
# --------------------------------------------------------------------------

# Función que se llama desde la escena de examen al finalizar una pregunta.
# (Ej: MetricsManager.update_methodology_score("OM1", true))
func update_methodology_score(exercise_type: String, was_correct: bool):
    var methodology_name = EXERCISE_TO_METHODOLOGY.get(exercise_type)
    
    if methodology_name and methodology_tracking.has(methodology_name):
        var tracker = methodology_tracking[methodology_name]
        
        # 1. Actualizar intentos y aciertos
        tracker.attempts += 1
        if was_correct:
            tracker.correct += 1
        
        # 2. Recalcular el score promedio (Dominio)
        if tracker.attempts > 0:
            tracker.score = float(tracker.correct) / float(tracker.attempts)
        else:
            tracker.score = 1.0
            
        print("Métrica de Metodología actualizada en MetricsManager:")
        print(" -> Metodología: %s (Score: %f)" % [methodology_name, tracker.score])
        
        # 3. 💾 LLAMADA A PERSISTENCIA EN BD (Firestore)
        # Aquí puedes llamar a una función de guardado que envíe solo 'methodology_tracking' a la BD
        # save_metrics_to_firestore(methodology_tracking)
        
    else:
        print("ERROR: Tipo de ejercicio (%s) no mapeado o metodología no encontrada." % exercise_type)
        
        
# Función utilizada por el menú para determinar qué ejercicio cargar a continuación.
func get_weakest_methodology() -> String:
    var weakest_methodology = ""
    var lowest_score = 1.1 # El score máximo es 1.0
    
    for methodology in methodology_tracking:
        var current_score = methodology_tracking[methodology].score
        
        if current_score < lowest_score:
            lowest_score = current_score
            weakest_methodology = methodology
            
    # Si todos los puntajes son 1.0 (ej. al inicio), devolvemos 'ABE' por defecto
    if lowest_score >= 1.0 and weakest_methodology == "":
        return "ABE" 
        
    return weakest_methodology
