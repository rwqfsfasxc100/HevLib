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
	"__get_lib_variables":[
		"Returns HevLib variables",
		"Has to be done on ready, as it relies upon the Autoloads having finished loading",
		"Some variables may take longer to load as they are fetched from the internet"
	],
	"__get_lib_pointers":[
		"Returns HevLib function files as an array.",
		"Using the optional return_as_full_path boolean will return each pointer's path rather than just the filename"
	],
	"__get_pointer_functions":[
		"Returns a dictionary of the pointer's functions",
		"Each key is the function name, with the respective array being notes on how the function is used",
		"Optional 'return_JSON' boolean returns a JSON-formatted string instead of a dictionary"
	],
	"__get_library_functionality":[
		"Returns a dictionary containing info on the entire library",
		" -> Top level of keys are the pointer names",
		" -> Child keys are equivalent to using __get_pointer_functions() on the respective pointers",
		"Optional 'return_JSON' boolean returns a JSON-formatted string instead of a dictionary"
	]
}

static func __get_lib_variables() -> Object:
	return preload("res://HevLib/pointers.gd").new().HevLib.__get_lib_variables()

static func __get_lib_pointers(return_as_full_path: bool = false) -> Array:
	return preload("res://HevLib/pointers.gd").new().HevLib.__get_lib_pointers(return_as_full_path)

static func __get_pointer_functions(pointer: String, return_JSON: bool = false) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().HevLib.__get_pointer_functions(pointer,return_JSON)


static func __get_library_functionality(return_JSON: bool = false) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().HevLib.__get_library_functionality(return_JSON)
