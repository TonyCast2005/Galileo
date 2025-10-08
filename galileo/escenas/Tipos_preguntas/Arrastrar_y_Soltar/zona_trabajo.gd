extends Panel

func can_drop_data(at_position, data):
	return data.has("tipo") and data["tipo"] == "bloque"

func drop_data(at_position, data):
	var nodo = data["nodo"]
	nodo.reparent(self)
