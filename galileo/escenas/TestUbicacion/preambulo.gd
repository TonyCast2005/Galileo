extends Control

var gato_dialogo
var indice_dialogo = 0
var dialogos = [
	"¡Hola! mi nombre es Galileo, yo te acompañaré a lo largo de tu aprendizaje.",
	"A continuación realizaremos un examen diagnostico,",
	"de este modo sabremos dónde posicionarte",
	"y podrás comenzar con tu aprendizaje!",
	"¿Listo?"
]

func _ready():
	iniciar_dialogo()

func iniciar_dialogo():
	gato_dialogo = preload("res://escenas/Gato_Instrucciones/Gato_Instrucciones.tscn").instantiate()
	add_child(gato_dialogo)
	gato_dialogo.global_position = Vector2(0, 40)

	gato_dialogo.textura_habla_personal = preload("res://assets/sprites/ui/Galileo/Feli.png")
	gato_dialogo.textura_idle_personal = preload("res://assets/sprites/ui/Galileo/Galileo Base.png")

	var tamaño_deseado = Vector2(256,256)
	var tamaño_textura = gato_dialogo.textura_habla_personal.get_size()
	gato_dialogo.gato.scale = tamaño_deseado / tamaño_textura

	await get_tree().process_frame

	gato_dialogo.dialogos = [ dialogos[indice_dialogo] ]
	gato_dialogo.mostrar_dialogo_actual()


func _on_botoncontinuar_pressed():
	if gato_dialogo.hablando:
		return

	indice_dialogo += 1

	if indice_dialogo < dialogos.size():
		gato_dialogo.dialogos = [ dialogos[indice_dialogo] ]
		gato_dialogo.indice = 0
		gato_dialogo.mostrar_dialogo_actual()
	else:
		print("✅ Diálogo finalizado. Cambiando de escena...")
		
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://escenas/TestUbicacion/Examen.tscn")
