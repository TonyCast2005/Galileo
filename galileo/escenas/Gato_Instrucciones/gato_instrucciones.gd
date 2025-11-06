extends Control

@onready var label_texto = $NinePatchRect/LabelTexto
@onready var gato = $Gato
@onready var sonido_habla = $SonidoHabla

# Texturas personalizadas
var textura_habla_personal: Texture = null
var textura_idle_personal: Texture = null

# Señal que se emite cuando termina el diálogo
signal dialogo_terminado

# Texturas por defecto
var texturas_habla = [
	preload("res://assets/sprites/ui/Galileo/Feli.png")
]
var textura_idle = preload("res://assets/sprites/ui/Galileo/Galileo Base.png")

# Diálogos de prueba (pueden ser sobrescritos desde fuera)
var dialogos: Array = [
	"Skibidi dibidi",
  
]

var indice = 0
var hablando = false
var animacion_tween: Tween

# Configuración del globo de texto
var max_lineas = 3
var max_chars_por_linea = 20
var lineas: Array = []


# 📖 Muestra el diálogo actual o emite señal si terminó
func mostrar_dialogo_actual():
	if indice >= dialogos.size():
		# Al terminar todos los diálogos
		gato.texture = textura_idle_personal if textura_idle_personal else textura_idle
		emit_signal("dialogo_terminado")  # ✅ Señal de que terminó
		queue_free()  # Cierra la escena del gato
		return

	label_texto.text = ""
	lineas.clear()
	hablar_texto(dialogos[indice])


# 💬 Hace que el gato hable letra por letra
func hablar_texto(texto: String) -> void:
	hablando = true
	sonido_habla.play()
	animar_gato_hablando()

	var velocidad = 0.04

	for i in texto.length():
		var letra = texto[i]

		# Agregar letra y manejar saltos de línea
		if lineas.size() == 0:
			lineas.append(letra)
		else:
			lineas[lineas.size() - 1] += letra

		if lineas[lineas.size() - 1].length() > max_chars_por_linea:
			lineas.append("")

		if lineas.size() > max_lineas:
			lineas.pop_front()

		label_texto.text = "\n".join(lineas)

		# Animación sonora y textura de hablar
		sonido_habla.pitch_scale = randf_range(0.9, 1.1)
		gato.texture = textura_habla_personal if textura_habla_personal else texturas_habla[randi() % texturas_habla.size()]

		await get_tree().create_timer(velocidad).timeout

	# Termina de hablar
	sonido_habla.stop()
	detener_animacion_gato()
	gato.texture = textura_idle_personal if textura_idle_personal else textura_idle
	hablando = false


# 😺 Movimiento del gato mientras habla
func animar_gato_hablando():
	if animacion_tween:
		animacion_tween.kill()

	var pos_base = gato.position
	animacion_tween = create_tween().set_loops()
	animacion_tween.tween_property(gato, "position:y", pos_base.y - 4, 0.1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	animacion_tween.tween_property(gato, "position:y", pos_base.y, 0.1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# 💤 Detiene la animación del gato
func detener_animacion_gato():
	if animacion_tween:
		animacion_tween.kill()
	gato.texture = textura_idle_personal if textura_idle_personal else textura_idle


# 👇 Avanza el diálogo con Enter o clic
func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_accept") and not hablando:
		indice += 1
		mostrar_dialogo_actual()
