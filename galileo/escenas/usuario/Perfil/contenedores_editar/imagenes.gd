extends Control

signal foto_seleccionada(nombre_foto)

func seleccionar_foto(foto_filename: String) -> void:
	# 1) Validar Globals
	if Globals.user == null or Globals.user.get("uid", "") == "":
		push_error("No hay usuario disponible para actualizar foto")
		return

	# 2) Actualizar Globals inmediatamente
	Globals.user["foto"] = foto_filename

	# 3) Guardar en Firebase
	var auth = load("res://escenas/usuario/registro/firebase_auth.gd").new()
	add_child(auth)

	var uid = Globals.user["uid"]
	var res = await auth.update_user_data(uid, {"foto": foto_filename})

	if res.has("error"):
		push_error("Error al guardar la foto en Firebase: %s" % res["error"])
	else:
		print("Foto actualizada correctamente:", foto_filename)

	# 4) Emitir señal para que EditarPerfil actualice sin recargar
	Globals.emit_signal("foto_actualizada", foto_filename)

	# 5) Cerrar selector
	queue_free()


# --------------------------
#  BOTONES → LLAMAN SOLO A seleccionar_foto()
# --------------------------

func _on_salir_pressed():
	queue_free()  # cerrar selector sin recargar perfil

func _on_aprendiz_veloz_pressed():
	seleccionar_foto("aprendizVeloz.png")

func _on_visual_pressed():
	seleccionar_foto("aprendizVisual.png")

func _on_caja_pressed():
	seleccionar_foto("cajadecartón.png")

func _on_gatocaja_pressed():
	seleccionar_foto("catbox.png")

func _on_bugs_pressed():
	seleccionar_foto("cazadorDeBugs.png")

func _on_noche_pressed():
	seleccionar_foto("noche.png")

func _on_experto_pressed():
	seleccionar_foto("expertoEnArduino.png")

func _on_explorador_pressed():
	seleccionar_foto("ExploradorInalcanzable.png")

func _on_pelea_techo_pressed():
	seleccionar_foto("PeleaTecho.png")

func _on_velocista_pressed():
	seleccionar_foto("gatoVelocista.png")

func _on_pez_gordo_pressed():
	seleccionar_foto("PezGordo.png")

func _on_pwm_pressed():
	seleccionar_foto("PWM.png")

func _on_libros_pressed():
	seleccionar_foto("teoricoNato.png")

func _on_primera_presa_pressed():
	seleccionar_foto("primeraPresa.png")
