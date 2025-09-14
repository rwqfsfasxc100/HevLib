extends HBoxContainer

var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

export var mod_box = preload("res://HevLib/scenes/mod_menu/mod_list/ModBox.tscn")

func _ready():
	var data = ManifestV2.__get_mod_data()["mods"]
	var groups = {}
	var mod_data = {}
	for mod in data:
		var fname = mod.split("/")[2]
		var info = data[mod]
		var zipinfo = ManifestV2.__match_mod_path_to_zip(mod)
		info.merge({"zip":zipinfo})
		if not fname in groups:
			groups.merge({fname:{}})
		groups[fname].merge({mod:info})
	for mod in groups:
		if groups[mod].keys().size() >= 2:
			var main = ""
			var minlength = INF
			for item in groups[mod]:
				var splitter = item.split(mod)[1]
				var split = splitter.split("/").size()
				if split < minlength:
					main = item
					minlength = split
			var mainmod = data[main].duplicate()
			mainmod.merge({"children":{}})
			for item in groups[mod]:
				if item != main:
					mainmod["children"].merge({item:groups[mod]})
			mod_data[main] = mainmod
		else:
			var modgroup = groups[mod].keys()[0]
			mod_data[modgroup] = data[modgroup]
	
	for mod in mod_data:
		var info = mod_data[mod]
		var button = mod_box.instance()
		button.MOD_INFO = info
		button.name = info["name"]
		button.ModContainer = get_parent()
		$ScrollContainer/VBoxContainer.add_child(button)
	var node = get_node("ScrollContainer/VBoxContainer")
	var index = 1
	var sorting  = true
	var sorted_nodes = node.get_children()
	sorted_nodes.sort_custom(self,"sort")
	for n in sorted_nodes:
		node.move_child(n,sorted_nodes.size())
	var BS = HBoxContainer.new()
	BS.set_script(load("res://HevLib/scenes/mod_menu/mod_list/BottomSeparator.gd"))
	BS.connect("visibility_changed",BS,"_visibility_changed")
	node.add_child(BS)
	

func sort(a: Node, b: Node): 
	return a.MOD_INFO.name.naturalnocasecmp_to(b.MOD_INFO.name) < 0
	
