extends Node

static func reparent(node, new_parent) -> void:
	var nodeCopy = node.duplicate()
	new_parent.add_child(nodeCopy)
	node.remove_and_skip()
	
