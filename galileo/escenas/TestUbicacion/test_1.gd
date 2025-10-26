extends Control

@onready var raiz = $ControlGato  # Nodo donde se instanciará el gato

var instancia_actual
var nivel_usuario: String = ""  # Guardamos el nivel elegido

# Botones de identificación
func _on_novato_pressed():
	nivel_usuario = "Novato"
	mostrar_gato([
		"¡Hola, principiante! 🐾",
		"Este examen es para conocerte mejor.",
		"Responde con sinceridad y yo te guiaré 😺."
	])

func _on_competente_pressed():
	nivel_usuario = "Competente"
	mostrar_gato([
		"¡Wow! 😺 Veo que ya tienes experiencia.",
		"Este examen pondrá a prueba tus conocimientos intermedios.",
		"¡Demuestra lo que sabes!"
	])

func _on_experimentado_pressed():
	nivel_usuario = "Experimentado"
	mostrar_gato([
		"¡Increíble! Eres todo un experto. 🧠",
		"Este examen será un reto digno de ti.",
		"Prepárate para demostrar tu maestría."
	])

# Botón para hacer examen si el usuario no sabe
func _on_no_se_pressed():
	get_tree().change_scene_to_file("res://escenas/TestUbicacion/Examen.tscn")


# Función para instanciar el gato con sus diálogos
func mostrar_gato(dialogos: Array):
	# Borrar instancia anterior
	if instancia_actual:
		instancia_actual.queue_free()

	var escena = preload("res://escenas/TestUbicacion/explicacion.tscn").instantiate()
	raiz.add_child(escena)
	instancia_actual = escena

	# Pasar los diálogos
	escena.set_instrucciones(dialogos)
