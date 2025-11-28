extends Node

var loading_scene := preload("res://TransicionCarga.tscn")
var loader_instance

func mostrar_loading():
    loader_instance = loading_scene.instantiate()
    get_tree().root.add_child(loader_instance)
    await loader_instance.fade_in()
    return loader_instance

func ocultar_loading():
    if loader_instance:
        await loader_instance.fade_out()
        loader_instance.queue_free()
        loader_instance = null

func cargar_con_loading(ruta: String, tiempo: float = 1.5) -> void:
    await mostrar_loading()
    await get_tree().create_timer(tiempo).timeout
    await ocultar_loading()
    get_tree().change_scene_to_file(ruta)
