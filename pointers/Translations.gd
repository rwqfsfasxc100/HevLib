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
	"__updateTL": [
		"Updates translations from a file in CSV format",
		" -> path - path to the file to fetch translations from",
		" -> delim - (optional) string, the delimiter used for the CSV. Defaults to \",\"",
		" -> fullLogging - (optional) whether to be verbose and state every translation made, or to display only the number of updated translations. Defaults to true"
	],
	"__updateTL_from_dictionary":[
		"Updates translations from a dictionary formatted as a translationDictionary.",
		"Use __translation_file_to_dictionary() to convert conventional CSV translation files to dictionary to provide info on how the formatting is done",
		"dictionary -> the dictionary where translations will be sourced",
		"fullLogging -> (optional) whether to use more verbose logging. Defaults to true"
	],
	"__fetch_all_translation_objects":[
		"Returns an array of all translation objects within the selected PID range",
		"number_of_objects_to_iterate_through -> (optional) integer for the maximum number of PIDs to iterate through. Defaults to 100000"
	],
	"__translation_file_to_dictionary":[
		"Converts a CSV formatted translation file to a translation dictionary",
		"path -> string to the translation file's location",
		"delimiter -> (optional) string containing the character to split the CSV line by. Defaults to '|"
	]
}

static func __updateTL(path:String, delim:String = ",", fullLogging:bool = true):
	preload("res://HevLib/pointers.gd").new().Translations.__updateTL(path,delim,fullLogging)
static func __updateTL_from_dictionary(dictionary:Dictionary, fullLogging:bool = true):
	preload("res://HevLib/pointers.gd").new().Translations.__updateTL_from_dictionary(dictionary,fullLogging)
static func __fetch_all_translation_objects(number_of_objects_to_iterate_through: int = 100000) -> Array:
	return preload("res://HevLib/pointers.gd").new().Translations.__fetch_all_translation_objects(number_of_objects_to_iterate_through)
static func __translation_file_to_dictionary(path: String, delimiter : String = "|") -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().Translations.__translation_file_to_dictionary(path,delimiter)
