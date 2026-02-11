extends "res://codex/TransitTip.gd"

var list = []
#const MV2 = preload("res://HevLib/pointers/ManifestV2.gd")
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
func _ready():
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
