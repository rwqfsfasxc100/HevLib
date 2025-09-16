extends HBoxContainer

var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

export var mod_box = preload("res://HevLib/ui/mod_menu/mod_list/ModBox.tscn")

export var info_icon = NodePath("")
export var info_name = NodePath("")
export var info_version = NodePath("")
export var info_author = NodePath("")
export var info_settings_button = NodePath("")
export var info_settings_icon = NodePath("")
export var info_desc = NodePath("")
export var info_desc_text = NodePath("")
export var info_desc_author = NodePath("")
export var info_desc_credits = NodePath("")





func _ready():
	var information_nodes = {
		"info_icon":get_node(info_icon),
		"info_name":get_node(info_name),
		"info_version":get_node(info_version),
		"info_author":get_node(info_author),
		"info_settings_button":get_node(info_settings_button),
		"info_settings_icon":get_node(info_settings_icon),
		"info_desc":get_node(info_desc),
		"info_desc_text":get_node(info_desc_text),
		"info_desc_author":get_node(info_desc_author),
		"info_desc_credits":get_node(info_desc_credits)
	}
	var data = ManifestV2.__get_mod_data()["mods"]
	var groups = {}
	var mod_data = {}
	var vdata = load("res://HevLib/ui/mod_menu/vanilla/data_dict.gd").get_script_constant_map()
	var vd = vdata.VANILLA
	mod_data.merge({"VANILLA":vd})
	
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
		button.information_nodes = information_nodes
		$ScrollContainer/VBoxContainer.add_child(button)
	var node = get_node("ScrollContainer/VBoxContainer")
	var index = 1
	var sorting  = true
	var sorted_nodes = node.get_children()
	sorted_nodes.sort_custom(self,"sort")
	for n in sorted_nodes:
		node.move_child(n,sorted_nodes.size())
	var BS = HBoxContainer.new()
	BS.set_script(load("res://HevLib/ui/mod_menu/mod_list/BottomSeparator.gd"))
	BS.connect("visibility_changed",BS,"_visibility_changed")
	BS.name = "HEVLIB_NODE_SEPARATOR_IGNORE_PLS"
	node.add_child(BS)
	

func sort(a: Node, b: Node): 
	return a.MOD_INFO.name.naturalnocasecmp_to(b.MOD_INFO.name) < 0
	
