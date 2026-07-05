extends "res://codex/TransitTip.gd"

var list = []

var pointers
func _ready():
	pointers = ModLoader._savedObjects[0]
	for i in range(tips):
		list.append(base % (i + 1))
	var tags = pointers.ManifestV2.__get_tags()
	if "TAG_ADD_TRANSIT_TIPS" in tags:
		for mod in tags["TAG_ADD_TRANSIT_TIPS"]:
			var data = tags["TAG_ADD_TRANSIT_TIPS"][mod]
			if typeof(data) == TYPE_ARRAY:
				list.append_array(data)
			elif typeof(data) == TYPE_STRING:
				list.append(data)

func _on_TransitTip_visibility_changed():
	text = list[randi() % list.size()]
