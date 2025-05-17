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
			set_ownership(child, set_owner_node)
