extends Node

var loading_scene := preload("res://TransicionCarga.tscn")
var loader_instance

func cargar_con_loading(ruta: String, tiempo: float = 1.4) -> void:
    loader_instance = loading_scene.instantiate()
    get_tree().root.add_child(loader_instance)

    await loader_instance.fade_in()   # Cubriendo la pantalla


    await get_tree().create_timer(1).timeout 
    # ⚡️ Cambiar escena mientras el panel está encima
    get_tree().change_scene_to_file(ruta)

    await get_tree().process_frame  # 1 frame para cargar bien

    await loader_instance.fade_out()  # Revelar nueva escena

    loader_instance.queue_free()
    loader_instance = null
