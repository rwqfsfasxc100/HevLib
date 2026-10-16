# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

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
