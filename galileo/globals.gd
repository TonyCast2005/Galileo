extends Node

signal foto_actualizada(foto_nueva)
var resultado_examen = {}

var user = {}
var user_uid = ""    
var user_data = {}   
var temp_preview_data = {}  

var firebase
var uid = ""
var email = ""
var nombre = ""

func _ready():
	firebase = load("res://escenas/usuario/registro/firebase_auth.gd").new()
