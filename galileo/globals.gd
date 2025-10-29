extends Node

var user = null

var resultado_examen = {}

func is_logged_in() -> bool:
	return user != null and user.has("uid")

func clear_user():
	user = null
