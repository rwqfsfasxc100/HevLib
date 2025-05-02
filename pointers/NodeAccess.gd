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
	"__reparent":[
		"Reparents a node to another node",
		"'node' is the node which you want to move to a new parent",
		"'parent_node' is the node which you would want to have made the new parent to 'node'"
	]
	}

static func __get_all_children(node, strip_supplied_node_from_array = false, return_only_paths = false, use_relative_paths = false):
	var f = load("res://HevLib/globals/get_all_children.gd").new()
	var s = f.get_all_children(node, strip_supplied_node_from_array, return_only_paths, use_relative_paths)
	return s

#static func __reparent(node, parent_node):
#	var f = load("res://HevLib/globals/reparent.gd")
#	f.reparent(node, parent_node)
