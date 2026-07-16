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
	"__get_all_children":[
		"Supplies all subsidual nodes of a node in an array",
		"Node input is the node to get all children of",
		"Optional strip_supplied_node_from_array used to ignore the supplied node in the output",
		"Optional return_only_paths used to provide only NodePaths in the array",
		"Optional use_relative_paths used to strip any path prefixes of node paths, ",
		" -> requires return_only_paths to be true to work",
	],
	"__claim_child_ownership":[
		"Sets the ownership of all recursive children of the provided node",
		"'node' is the node which you want to claim all subsequent ownership for"
	],
	"__is_instanced_from_scene":[
		"Checks if a node is instanced from a file",
		"'p_node' is the node that is being checked"
	],
	"__dynamic_crew_expander":[
		"Creates a valid scene file that can be used to extend the number of crew capable of boarding a derelict",
		"folder_path -> the folder where the scene will be stored",
		"max_crew -> the desired new maximum crew count that can board derelicts. Fails when equal to 24 or less due to HevLib doing it automatically",
		"Returns a string as the filepath to the generated scene. The scene is given a generated name, so be careful which folder is chosen.",
		"If the function fails, an empty string is returned instead."
	],
	"__convert_var_from_string":[
		"Converts a variant stored literally as a string to the respective variable",
		"For instance, Vector2(x,y) is stored as \"Vector2(x,y)\", a string ABC is stored as \"\"ABC\"\" (Note that the string has to use double quotations to ensure that one set of quotes is stored)",
		"string -> the string used to convert to the variant",
		"folder -> (optional) the folder used to store the cache file used in the operation. Defaults to \"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/file_caches\"",
		"Returns the variant"
	],
	"__remove_scripts":[
		"Removes script of node and all child nodes",
		"node -> the object to remove script and recursive child scripts from"
	]
}

static func __get_all_children(node, strip_supplied_node_from_array = false, return_only_paths = false, use_relative_paths = false):
	return preload("res://HevLib/pointers.gd").new().NodeAccess.__get_all_children(node,strip_supplied_node_from_array,return_only_paths,use_relative_paths)
static func __claim_child_ownership(node:Node):
	preload("res://HevLib/pointers.gd").new().NodeAccess.__claim_child_ownership(node)
static func __is_instanced_from_scene(p_node):
	return preload("res://HevLib/pointers.gd").new().NodeAccess.__is_instanced_from_scene(p_node)
static func __dynamic_crew_expander(folder_path: String, max_crew:int = 24) -> String:
	return preload("res://HevLib/pointers.gd").new().NodeAccess.__dynamic_crew_expander(folder_path,max_crew)
static func __convert_var_from_string(string : String, folder : String = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/file_caches"):
	return preload("res://HevLib/pointers.gd").new().DataFormat.__convert_var_from_string(string,folder)

static func __remove_scripts(node):
	preload("res://HevLib/pointers.gd").new().NodeAccess.__remove_scripts(node)

