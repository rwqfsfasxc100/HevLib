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
	"__load_manifest_from_file":[
		"Loads manifest data and returns it as a dictionary",
		"less preferable than __get_mod_main outside of more specific use-cases"
	],
	"__load_file":[
		"Specific function for Mod Menu behaviour",
		"Requires 6 inputs",
		" -> modDir is the mod main's directory (form of res://Mod_Folder/ModMain.gd)",
		" -> zipDir is the directory of the mod's zip (form of mod_folder/mod.zip)",
		" -> hasManifest determines whether the manifest should be used",
		" -> manifestDirectory is the directory of the mod.manifest file (form of res://Mod_Folder/mod.manifest)",
		" -> hasIcon determines whether the custom mod icon should be used",
		" -> iconDir is the directory of the icon.stex file (form of res://Mod_Folder/icon.stex",
		"less preferable than __get_mod_main outside of more specific use-cases"
	],
	"__get_mod_main":[
		"Returns 16 lines of text, split by a newline (\n), of mod data in a single string using the mod menu data standard",
		"Optional split_into_array bool converts the data into an array preemptively",
		"Preferable use of fetching mod data compared to __load_file and __load_manifest_from_file as it combines several of the previous helper functions into one, and removes the need for overhead code"
	]
}

static func __load_manifest_from_file(manifest: String) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ManifestV1.__load_manifest_from_file(manifest)
static func __load_file(modDir: String, zipDir: String, hasManifest: bool, manifestDirectory: String, hasIcon: bool, iconDir: String) -> String:
	return preload("res://HevLib/pointers.gd").new().ManifestV1.__load_file(modDir,zipDir,hasManifest,manifestDirectory,hasIcon,iconDir)
static func __get_mod_main(file: String, split_into_array: bool = false) -> String:
	return preload("res://HevLib/pointers.gd").new().ManifestV1.__get_mod_main(file,split_into_array)
