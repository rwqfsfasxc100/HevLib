extends Node

static func sift_ship_config(dict,grab,cfgs_to_ignore:Array,parent = ""):
	for i in cfgs_to_ignore:
		dict.erase(i)
	var arr = []
	var splitter = "."
	var prefab = ""
	if parent != "":
		prefab = parent + splitter
	for key in dict:
		var kdata = dict[key]
		var p = prefab + key
		match typeof(kdata):
			TYPE_STRING:
				if kdata in grab:
					arr.append(p + splitter + kdata)
			TYPE_DICTIONARY:
				arr.append_array(sift_ship_config(kdata,grab,[],p))
	return arr
