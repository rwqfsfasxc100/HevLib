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
	"__array_to_string":[
		"Concatenates all parts of an array into a string",
		"Returns a string in the form of array[0] + array[1] + ... + array[n] etc."
	],
	"__format_for_large_numbers":[
		"Formats numbers into a human-readable form, separated with a comma"
	],
	"__compare_with_byte_array":[
		"Compared two strings bitwise to make a more efficient check",
		"input_string -> the first string to compare",
		"comparison_string -> the second string to compare",
		"returns a boolean whether the scripts match"
	],
	"__rotate_point":[
		"Rotates a Vector2 point around the origin",
		"point -> Vector2 point to be rotated (this is set as angle 0)",
		"angle -> float to set as the desired rotation",
		"degrees -> (optional) whether to have the angle treated as degrees rather than radians. Defaults to true"
	],
	"__sift_dictionary":[
		"Searches for any matches in keys or values within a dictionary",
		"dictionary -> the dictionary to search through",
		"search_keys -> array of keys and values to look for. Can contain any type, will return any match.",
		"Returns an array of the values matched from within the search_keys array"
	],
	"__convert_arr_to_vec2arr":[
		"Returns a PoolVector2Array from an array of integers and floats",
		"array -> Array used as the input integers/floats. Must have an even size and contain only ints or floats"
	],
	"__get_vanilla_version":[
		"Gets the vanilla game version",
		"get_from_files -> (optional) bool deciding whether to get the version from the files. Generally slower than it being disabled, however is the only way to get it before the onready phase. Only works in debug builds due to bytecode compiled data"
	],
	"__compare_versions":[
		"Compares two sets of versions. If the first one is equal to or newer, returns true, otherwise returns false",
		"First three int inputs are the major, minor and bugfix for the first version",
		"Second three int inputs are the major, minor and bugfix for the second version",
	],
	"__sift_ship_config":[
		"Ship config specific equivalent to __sift_dictionary",
		"Allows you to remove specific keys from the top level of the dictionary, useful for getting rid of specific config entries that may sour the data",
		"dictionary -> the dictionary to search through",
		"search_keys -> array of keys and values to look for. Can contain any type, will return any match.",
		"cfgs_to_ignore -> (optional) array used to remove keys from the top level of the dictionary",
		"Returns an array of the values matched from within the search_keys array in config format with the system appended to the end, e.g. weaponSlot.main.type.SYSTEM_EMD14"
	],
	"__get_script_constant_map_without_load":[
		"Fetches and returns the constant map of a script without loading and initializing the script, useful to prevent double loading of ModMain.gd files",
		"script_path -> string used to provide the full filepath to the script file"
	],
	"__trim_scripts":[
		"Takes a script and extracts only script variables and constants from it",
		"Returns an array with three values",
		"First value is a string containing a valid script with only the original script's variables and constants",
		"Second value is an array of all script variable names in order",
		"Third value is an array of all constant names in order",
		"file_path -> string for the input script's filepath"
	]
}

static func __array_to_string(arr: Array) -> String:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__array_to_string(arr)
static func __format_for_large_numbers(num: int) -> String:
	return CurrentGame.formatThousands(num)
static func __compare_with_byte_array(input_string: String, comparison_string: String) -> bool:
	return input_string == comparison_string
static func __rotate_point(point: Vector2, angle: float, degrees:bool = true) -> Vector2:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__rotate_point(point,angle,degrees)
static func __get_vanilla_version(get_from_files: bool = false) -> Array:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__get_vanilla_version()
static func __sift_dictionary(dictionary: Dictionary,search_keys: Array) -> Array:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__sift_dictionary(dictionary,search_keys)
static func __convert_arr_to_vec2arr(array: Array) -> PoolVector2Array:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__convert_arr_to_vec2arr(array)
static func __compare_versions(primary_major : int,primary_minor : int,primary_bugfix : int, compare_major : int, compare_minor : int, compare_bugfix : int) -> bool:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__compare_versions(primary_major,primary_minor,primary_bugfix,compare_major,compare_minor,compare_bugfix)
static func __sift_ship_config(dictionary: Dictionary,search_keys: Array, cfgs_to_ignore:Array) -> Array:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__sift_ship_config(dictionary,search_keys,cfgs_to_ignore)
static func __get_script_constant_map_without_load(script_path : String) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__get_script_constant_map_without_load(script_path)
static func __trim_scripts(file_path: String) -> Array:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__trim_scripts(file_path)
static func __get_script_variables_without_load(script_path : String) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().DataFormat.__get_script_variables_without_load(script_path)
