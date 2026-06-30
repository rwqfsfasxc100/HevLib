extends Node
 
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

const pointers = preload("res://HevLib/pointers.gd")

static func __get_all_children(node, strip_supplied_node_from_array = false, return_only_paths = false, use_relative_paths = false):
	return pointers.new().NodeAccess.__get_all_children(node,strip_supplied_node_from_array,return_only_paths,use_relative_paths)
static func __claim_child_ownership(node:Node):
	pointers.new().NodeAccess.__claim_child_ownership(node)
static func __is_instanced_from_scene(p_node):
	return pointers.new().NodeAccess.__is_instanced_from_scene(p_node)
static func __dynamic_crew_expander(folder_path: String, max_crew:int = 24) -> String:
	return pointers.new().NodeAccess.__dynamic_crew_expander(folder_path,max_crew)
static func __convert_var_from_string(string : String, folder : String = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/file_caches"):
	return pointers.new().DataFormat.__convert_var_from_string(string,folder)

static func __remove_scripts(node):
	pointers.new().NodeAccess.__remove_scripts(node)

