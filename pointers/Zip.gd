extends Node

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
	"__get_zip_content":[
		"Lists all files in the zip by paths relative to the mod's name folder",
		" -> i.e. a zip only containing a folder and a text file return [folder/, file.txt]",
		"Returns an array of file paths in zip-relative form, stored alphabetically",
		"Optional Strip_Parent_Folder boolean removes the first folder item before the slash.",
		"Optional To_Lower_Case boolean converts all characters to lower"
	],
	"__fetch_file_from_zip":[
		"Loads a zip file and stores the requested files from paths relative to the root",
		"If you intend on taking data from a zip multiple times, this is a preferable method as it loads it to disk for future reference instead",
		"Does not work for fetching compressed data from within a zip (images, archives, .stex streams, etc)",
		"Defer to external programs for full unzip control",
		"Generates all folders in the zip file before handling the files to ensure they can save properly, but may cause clutter",
		"Outputs an array of all files saved to disk",
		"Handles case insensitivities"
	]
}


static func __get_zip_content(path: String, Strip_Parent_Folder: bool = false, To_Lower_Case: bool = false) -> Array:
	return preload("res://HevLib/pointers.gd").new().Zip.__get_zip_content(path,Strip_Parent_Folder,To_Lower_Case)

static func __fetch_file_from_zip(path: String, Destination_Folder_Path: String, Desired_File_Paths: Array) -> Array:
	return preload("res://HevLib/pointers.gd").new().Zip.__fetch_file_from_zip(path, Destination_Folder_Path, Desired_File_Paths)
