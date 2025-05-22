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
	]
	}

static func __get_all_children(node, strip_supplied_node_from_array = false, return_only_paths = false, use_relative_paths = false):
	var f = load("res://HevLib/globals/get_all_children.gd").new()
	var s = f.get_all_children(node, strip_supplied_node_from_array, return_only_paths, use_relative_paths)
	return s

static func __claim_child_ownership(node:Node):
	var f = load("res://HevLib/scripts/claim_child_ownership.gd").new()
	f.claim_child_ownership(node)

static func __is_instanced_from_scene(p_node):
	var f = load("res://HevLib/scripts/claim_child_ownership.gd").new()
	var s = f.__is_instanced_from_scene(p_node)
	return s
