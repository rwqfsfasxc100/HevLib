extends Node

func claim_child_ownership(node: Node):
	var children = node.get_children()
	for child in children:
		set_ownership(child, node)

func set_ownership(current_node: Node,set_owner_node: Node):
	current_node.set_owner(set_owner_node)
	if current_node.get_child_count() >= 1:
		var children = current_node.get_children()
		for child in children:
			if not __is_instanced_from_scene(child.get_parent()):
				set_ownership(child, set_owner_node)

static func __is_instanced_from_scene(p_node):
	if not p_node.filename.empty():
		return true
	return false
