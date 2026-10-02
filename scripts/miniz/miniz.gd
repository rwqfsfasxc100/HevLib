extends Reference
class_name MINIZ

# Translation layer to permit proper autocompletion
# SCRIPT USAGE: var miniz:MINIZ = load("res://HevLib/scripts/miniz/miniz.gd").new()
# See res://HevLib/scripts/miniz/README.md for complete usage instructions

var compression_level : int setget set_compression_level, get_compression_level


func set_compression_level(level : int) -> void:
	miniz.compression_level = level


func get_compression_level() -> int:
	return miniz.compression_level


func open_read(path : String) -> int:
	return miniz.open_read(path)


func open_write(path : String) -> int:
	return miniz.open_write(path)


func open_buffer(data : PoolByteArray) -> int:
	return miniz.open_buffer(data)


func open_append(path: String) -> int:
	return miniz.open_append(path)


func open_append_buffer(data : PoolByteArray) -> int:
	return miniz.open_append_buffer(data)


func open_write_buffer() -> int:
	return miniz.open_write_buffer()


func close() -> int:
	return miniz.close()


func close_buffer() -> PoolByteArray:
	return miniz.close_buffer()


func flush() -> int:
	return miniz.flush()


func flush_to_file(path: String) -> int:
	return miniz.flush_to_file(path)


func flush_to_buffer() -> PoolByteArray:
	return miniz.flush_to_buffer()


func is_open() -> bool:
	return miniz.is_open()


func get_last_error() -> String:
	return miniz.get_last_error()


func get_file_count() -> int:
	return miniz.get_file_count()


func list_files() -> PoolStringArray:
	return miniz.list_files()


func file_exists(file_path : String) -> bool:
	return miniz.file_exists(file_path)


func get_file_info(file_path : String) -> Dictionary:
	return miniz.get_file_info(file_path)


func read_file(file_path : String) -> PoolByteArray:
	return miniz.read_file(file_path)


func read_file_as_string(file_path : String) -> String:
	return miniz.read_file_as_string(file_path)


func extract_file(file_path : String, dest_path : String) -> int:
	return miniz.extract_file(file_path, dest_path)


func extract_all(dest_dir : String) -> int:
	return miniz.extract_all(dest_dir)


func validate() -> int:
	return miniz.validate()


func add_file_from_bytes(file_path : String, data : PoolByteArray, overwrite : bool = false) -> int:
	return miniz.add_file_from_bytes(file_path, data, overwrite)


func add_file_from_string(file_path : String, text : String, overwrite : bool = false) -> int:
	return miniz.add_file_from_string(file_path, text, overwrite)


func add_file(file_path : String, src_path : String, overwrite : bool = false) -> int:
	return miniz.add_file(file_path, src_path, overwrite)


func add_directory(file_path : String) -> int:
	return miniz.add_directory(file_path)


func add_folder(source_path : String, overwrite : bool = false) -> int:
	return miniz.add_folder(source_path, overwrite)


func add_folder_as(source_path : String, dir_path : String, overwrite : bool = false) -> int:
	return miniz.add_folder_as(source_path, dir_path, overwrite)


func remove_file(file_path : String) -> int:
	return miniz.remove_file(file_path)


func remove_files(file_paths : PoolStringArray) -> int:
	return miniz.remove_files(file_paths)


func remove_folder(file_path : String) -> int:
	return miniz.remove_folder(file_path)


func compress_zlib(data : PoolByteArray) -> PoolByteArray:
	return miniz.compress_zlib(data)


func decompress_zlib(data : PoolByteArray, max_size : int = 0) -> PoolByteArray:
	return miniz.decompress_zlib(data, max_size)


func crc32(data : PoolByteArray) -> int:
	return miniz.crc32(data)


func get_miniz_version() -> String:
	return miniz.get_miniz_version()



var miniz

func _init():
	miniz = load("res://HevLib/scripts/miniz/miniz.gdns").new()
