extends Node

func get_all_children(in_node, strip_supplied_node_from_array = false, return_only_paths = false, use_relative_paths = false):
	var children = getAllChildren(in_node)
	if strip_supplied_node_from_array:
		children = strip_node(in_node, children)
	if return_only_paths:
		children = returnPaths(children, use_relative_paths, in_node)
	return children

func getAllChildren(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = getAllChildren(child,arr)
	return arr

func strip_node(in_node, arr):
	var paths = []
	for m in arr:
		var selfPath = in_node.get_path()
		var modify = str(m.get_path()).split(selfPath)
		if modify[1] != "":
			paths.append(m)
	return paths

func returnPaths(arr, relative, in_node):
	var parentPath = str(in_node.get_path())
	var paths = []
	for m in arr:
		var path = m.get_path()
		paths.append(path)
	if relative:
		var rel = []
		for i in paths:
			var ps = str(i).split(parentPath)[1]
			var tsu = str(ps).lstrip("/")
			rel.append(tsu)
		paths = rel
	return paths
