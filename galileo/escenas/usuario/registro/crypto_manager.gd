extends Node

var key: PackedByteArray

func _ready():
	var file = FileAccess.open("res://keys/aes.key", FileAccess.READ)
	if file:
		key = file.get_buffer(file.get_length())
		print("Llave AES cargada:", key.size(), "bytes")
	else:
		push_error("No se pudo cargar la llave AES")

# Genera un IV aleatorio para cada cifrado
func generate_iv() -> PackedByteArray:
	var iv = PackedByteArray()
	for i in range(16): # 128 bits
		iv.append(randi() % 256)
	return iv

# 🔐 Encriptar contraseña (AES CBC + Base64)
func encrypt_password(password: String) -> String:
	var aes = AESContext.new()
	var iv = generate_iv()
	aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv)

	var data = password.to_utf8_buffer()
	while data.size() % 16 != 0:
		data.append(0)

	var encrypted = aes.update(data)
	aes.finish()

	# Combinar IV + datos cifrados (para poder descifrar después)
	var full_data = iv + encrypted
	return Marshalls.raw_to_base64(full_data)

# 🔓 Desencriptar contraseña
func decrypt_password(encrypted_b64: String) -> String:
	var full_data = Marshalls.base64_to_raw(encrypted_b64)

	# Separar IV (primeros 16 bytes) y datos
	var iv = full_data.slice(0, 16)
	var data = full_data.slice(16, full_data.size())

	var aes = AESContext.new()
	aes.start(AESContext.MODE_CBC_DECRYPT, key, iv)

	var decrypted = aes.update(data)
	aes.finish()

	# Quitar padding
	while decrypted.size() > 0 and decrypted[-1] == 0:
		decrypted.resize(decrypted.size() - 1)

	return decrypted.get_string_from_utf8()
