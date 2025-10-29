# res://scripts/crypto_manager.gd
extends Node

var key: PackedByteArray = PackedByteArray()

func _ready() -> void:
	var path = "res://keys/aes.key"
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		key = f.get_buffer(f.get_length())
		f.close()
		print("crypto_manager: llave cargada", key.size(), "bytes")
	else:
		push_error("crypto_manager: no se encontró aes.key en %s" % path)

func generate_iv() -> PackedByteArray:
	var iv = PackedByteArray()
	for i in range(16):
		iv.append(randi() % 256)
	return iv

func encrypt_data(data: String) -> String:
	if key.is_empty():
		push_error("crypto_manager: llave AES no cargada")
		return ""
	var aes = AESContext.new()
	var iv = generate_iv()
	aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv)
	var buf = data.to_utf8_buffer()
	while buf.size() % 16 != 0:
		buf.append(0)
	var enc = aes.update(buf)
	aes.finish()
	return Marshalls.raw_to_base64(iv + enc)

func decrypt_data(encrypted_b64: String) -> String:
	if key.is_empty():
		push_error("crypto_manager: llave AES no cargada")
		return ""
	var full = Marshalls.base64_to_raw(encrypted_b64)
	if full.size() < 16:
		push_error("crypto_manager: datos cifrados inválidos")
		return ""
	var iv = full.slice(0, 16)
	var data = full.slice(16, full.size())
	var aes = AESContext.new()
	aes.start(AESContext.MODE_CBC_DECRYPT, key, iv)
	var dec = aes.update(data)
	aes.finish()
	while dec.size() > 0 and dec[-1] == 0:
		dec.resize(dec.size() - 1)
	return dec.get_string_from_utf8()
