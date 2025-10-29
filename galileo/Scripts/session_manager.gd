extends Node

const FILE_PATH := "user://session.dat"
const CRYPTO_PATH := "res://escenas/usuario/registro/crypto_manager.gd"

var crypto: Node = null

func _ready() -> void:
	# Inicializa el gestor de cifrado
	_init_crypto()

# Inicializa el crypto_manager
func _init_crypto() -> void:
	if crypto != null:
		return

	if not ResourceLoader.exists(CRYPTO_PATH):
		push_error("session_manager: no se encontró crypto_manager en %s" % CRYPTO_PATH)
		return

	var CryptoScript = preload(CRYPTO_PATH)
	crypto = CryptoScript.new()
	add_child(crypto) # asegura que _ready() del crypto_manager se ejecute y cargue la llave

# Guarda sesión cifrada
func save_session(id_token: String, refresh_token: String, email: String, uid: String) -> void:
	_init_crypto()

	if crypto == null:
		push_error("session_manager: crypto no disponible. No se pudo guardar sesión.")
		return

	var data = {
		"id_token": id_token,
		"refresh_token": refresh_token,
		"email": email,
		"uid": uid
	}

	var json = JSON.stringify(data)
	var encrypted := ""

	if crypto.has_method("encrypt_data"):
		encrypted = crypto.encrypt_data(json)
	else:
		push_error("session_manager: crypto_manager no tiene encrypt_data(). Revisa crypto_manager.gd")
		return

	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(encrypted)
		file.close()
		print("Sesión guardada encriptada correctamente.")
	else:
		push_error("session_manager: no se pudo abrir archivo para escribir %s" % FILE_PATH)

# Carga sesión descifrada
func load_session() -> Dictionary:
	_init_crypto()

	if crypto == null:
		push_error("session_manager: crypto no disponible. No se pudo cargar sesión.")
		return {}

	if not FileAccess.file_exists(FILE_PATH):
		return {}

	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	if not file:
		push_error("session_manager: no se pudo abrir el archivo de sesión %s" % FILE_PATH)
		return {}

	var encrypted = file.get_as_text()
	file.close()

	if not crypto.has_method("decrypt_data"):
		push_error("session_manager: crypto_manager no tiene decrypt_data(). Revisa crypto_manager.gd")
		return {}

	var decrypted := ""
	decrypted = crypto.decrypt_data(encrypted)

	var parsed = JSON.parse_string(decrypted)
	if typeof(parsed) == TYPE_DICTIONARY:
		print("Sesión cargada correctamente:", parsed)
		return parsed
	else:
		push_error("session_manager: json de sesión inválido después de descifrar.")
		return {}

# Elimina la sesión
func clear_session() -> void:
	if FileAccess.file_exists(FILE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			if dir.file_exists("session.dat"):
				dir.remove("session.dat")
				print("Sesión eliminada correctamente.")
			else:
				print("session_manager: no existe session.dat")
		else:
			push_error("session_manager: no se pudo abrir user:// para eliminar session.dat")
