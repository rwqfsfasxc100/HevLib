extends PanelContainer

var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

var filter_box_nd = preload("res://HevLib/ui/mod_menu/filters/FilterBox.tscn")

var tags = {}

var tag_visibility = {}

var mod_visibility = []

var filtering = false

func _ready():
	tags = ManifestV2.__get_tags()
	for tag in tags:
		var node = filter_box_nd.instance()
		node.name = tag
		node.get_node("P/Label").text = tag
		node.get_node("CheckButton").pressed = true
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(node)
		tag_visibility.merge({tag:false})
	

func update_filters(tag,change):
	tag_visibility[tag] = change
	mod_visibility = []
	var currently_filtering_tags = []
	var has_filters = false
	for t in tag_visibility:
		if tag_visibility[t] == true:
			has_filters = true
			currently_filtering_tags.append(t)
	if has_filters:
		filtering = true
	else:
		filtering = false
	for tag in currently_filtering_tags:
		var mods = tags[tag]
		for mod in mods:
			if mod in mod_visibility:
				pass
			else:
				mod_visibility.append(mod)
