extends Node

static func reparent(node: Node, new_parent: Node) -> void:
	var nodeCopy = node.duplicate()
	new_parent.call_deferred("add_child", nodeCopy)
	node.call_deferred("remove_and_skip")
	
