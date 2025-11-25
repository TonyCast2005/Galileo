extends Node2D

func verificar_codigo():
	var zonas = get_tree().get_nodes_in_group("zone_respuesta")

	
	# Si tus zonas están ordenadas horizontalmente, cambia a 'x'
	zonas.sort_custom(func(a, b): return a.position.y < b.position.y)
	
	var correcto = true
	var codigo_actual = ""

	print("\n🔍 Iniciando verificación...\n")

	for zona in zonas:
		if zona.bloque_actual:
			var palabra_bloque = zona.bloque_actual.palabra.strip_edges()
			var palabra_correcta = zona.palabra_correcta.strip_edges()
			codigo_actual += palabra_bloque + " "

			if palabra_bloque != palabra_correcta:
				print("❌ Error en zona:", zona.name, 
					  " — esperado:", palabra_correcta, 
					  " — obtenido:", palabra_bloque)
				correcto = false
			else:
				print("✅ Correcto en zona:", zona.name, "-", palabra_bloque)
		else:
			print("⚠️ Zona vacía:", zona.name)
			correcto = false

	print("\nCódigo formado:", codigo_actual)

	if correcto:
		print("🎉 Código completo correcto ✅\n")
	else:
		print("⚠️ Hay errores en el orden o palabras ❌\n")


func _on_verificar_pressed():
	print("🔘 Botón 'Verificar' presionado")
	verificar_codigo()
