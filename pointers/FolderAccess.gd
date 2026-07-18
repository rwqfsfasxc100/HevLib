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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

var developer_hint = {
	"__check_folder_exists":[
		"Ensures the supplied folder exists",
		"If folder exists, returns true",
		"Otherwise, attempts to create it. If it succeeds, returns true, else returns false"
	],
	"__recursive_delete":[
		"Recursively deletes the provided folder",
		"Returns false if the folder doesn't load"
	],
	"__get_first_file":[
		"Supplies the first file in a folder",
		"If no files exists, returns false"
	],
	"__fetch_folder_files":[
		"Returns the file contents of a folder",
		" -> folder - path to the folder to check the contents of",
		" -> showFolders - whether to add folders into the array of files. each folder will end with a slash to identify",
		" -> returnFullPath - whether to return the full paths of the files and folders, rather the names"
	],
	"__copy_file":[
		"Copies (and overrides) a file to a folder, and can account for globalized and Windows paths",
		"file -> string for the path to the file, can be global or local path",
		"folder -> string for the path to the folder, can be global or local path"
	],
	"__get_folder_structure":[
		"Recursive equivalent to __fetch_folder_files",
		"folder -> absolute path to the folder desired. Can be literal, res://, or user://",
		"store_file_content -> (optional) bool to decide whether to store a stringified version of each file's content"
	]
}

static func __check_folder_exists(folder: String, status_array: bool = false) -> bool:
	return preload("res://HevLib/pointers.gd").new().FolderAccess.__check_folder_exists(folder,status_array)
static func __recursive_delete(path: String):
	return preload("res://HevLib/pointers.gd").new().FolderAccess.__recursive_delete(path)
static func __get_first_file(folder: String) -> String:
	return preload("res://HevLib/pointers.gd").new().FolderAccess.__get_first_file(folder)
static func __fetch_folder_files(folder: String, showFolders: bool = false, returnFullPath: bool = false,globalizePath: bool = false) -> Array:
	return preload("res://HevLib/pointers.gd").new().FolderAccess.__fetch_folder_files(folder,showFolders,returnFullPath,globalizePath)

static func __copy_file(file, folder):
	preload("res://HevLib/pointers.gd").new().FileAccess.__copy_file(file,folder)
static func __get_folder_structure(folder,store_file_content = false):
	return preload("res://HevLib/pointers.gd").new().FolderAccess.__get_folder_structure(folder,store_file_content)

static func __get_modmain_files() -> Array:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_modmain_files()
