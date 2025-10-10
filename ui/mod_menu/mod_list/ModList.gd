extends HBoxContainer

var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

export var mod_box = preload("res://HevLib/ui/mod_menu/mod_list/ModBox.tscn")

export var info_icon = NodePath("")
export var info_name = NodePath("")
export var info_version = NodePath("")
export var info_priority = NodePath("")
export var info_mod_id = NodePath("")
export var info_author = NodePath("")
export var info_settings_button = NodePath("")
export var info_settings_icon = NodePath("")
export var info_desc = NodePath("")
export var info_desc_text = NodePath("")
export var info_desc_author = NodePath("")
export var info_desc_credits = NodePath("")
export var info_links_button = NodePath("")
export var info_bugreports_button = NodePath("")

export var count_label_path = NodePath("")
onready var count_label = get_node(count_label_path)
export var filter_btn_path = NodePath("")
onready var filter_btn = get_node(filter_btn_path)

export var links_menu_path = NodePath("")
onready var links_menu = get_node(links_menu_path)
export var settings_menu_path = NodePath("")
onready var settings_menu = get_node(settings_menu_path)

onready var listContainer = $ScrollContainer/VBoxContainer

export var conflict_button_path = NodePath("")
export var dependancies_button_path = NodePath("")
export var updates_button_path = NodePath("")

onready var conflict_button = get_node(conflict_button_path)
onready var dependancies_button = get_node(dependancies_button_path)
onready var updates_button = get_node(updates_button_path)

func about_to_show():
	var restart_dialog = subroot.restart_menu
	restart_dialog.get_node("PanelContainer/VBoxContainer/HBoxContainer/Restart/Button").connect("pressed",self,"_restart")
	restart_dialog.get_node("PanelContainer/VBoxContainer/HBoxContainer/Exit/Button").connect("pressed",self,"_exit")
	restart_dialog.get_node("PanelContainer/VBoxContainer/HBoxContainer/Cancel/Button").connect("pressed",self,"restart_cancel")
	var nodes = listContainer.get_children()
	if nodes.size() >= 2:
		nodes[0]._pressed()
	filter_btn.current_text = ""
	filter_btn.keys_pressed = ""

var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")

export var subroot_path = NodePath("")
onready var subroot = get_node(subroot_path)

func _restart():
	OS.set_restart_on_exit(true,OS.get_cmdline_args())

func _exit():
	OS.kill(OS.get_process_id())

func restart_cancel():
	subroot.restart_menu.hide()

func _ready():
	
	
	var information_nodes = {
		"mod_list":self,
		"info_icon":get_node(info_icon),
		"info_name":get_node(info_name),
		"info_version":get_node(info_version),
		"info_priority":get_node(info_priority),
		"info_author":get_node(info_author),
		"info_mod_id":get_node(info_mod_id),
		"info_settings_button":get_node(info_settings_button),
		"info_settings_icon":get_node(info_settings_icon),
		"info_desc":get_node(info_desc),
		"info_desc_text":get_node(info_desc_text),
		"info_desc_author":get_node(info_desc_author),
		"info_desc_credits":get_node(info_desc_credits),
		"info_links_button":get_node(info_links_button),
		"info_bugreports_button":get_node(info_bugreports_button),
		"count_label_path":get_node(count_label_path),
		"filter_btn_path":get_node(filter_btn_path),
		"links_menu_path":get_node(links_menu_path),
		"settings_menu":get_node(settings_menu_path),
		"conflict_button":get_node(conflict_button_path),
		"dependancies_button":get_node(dependancies_button_path),
		"updates_button":get_node(updates_button_path),
	}
	var data = ManifestV2.__get_mod_data()["mods"]
	var groups = {}
	var mod_data = {}
	var vdata = load("res://HevLib/ui/mod_menu/vanilla/data_dict.gd").get_script_constant_map()
	var vd = vdata.VANILLA
	
	var ver = DataFormat.__get_vanilla_version()
	var verstr = str(ver[0]) + "." + str(ver[1]) + "." +str(ver[2])
	
	vd["manifest"]["manifest_data"]["version"]["version_major"] = ver[0]
	vd["manifest"]["manifest_data"]["version"]["version_minor"] = ver[1]
	vd["manifest"]["manifest_data"]["version"]["version_bugfix"] = ver[2]
	vd["manifest"]["manifest_data"]["version"]["version_string"] = verstr
	
	vd["version_data"]["version_major"] = ver[0]
	vd["version_data"]["version_minor"] = ver[1]
	vd["version_data"]["version_bugfix"] = ver[2]
	vd["version_data"]["full_version_array"] = ver
	vd["version_data"]["full_version_string"] = verstr
	vd["version_data"]["legacy_mod_version"] = verstr
	
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
					mainmod["children"].merge({item:groups[mod][item]})
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
		listContainer.add_child(button)
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
	
export var desc_scroll_box = NodePath("")
onready var dp = get_node(desc_scroll_box)

func _draw():
	var dp_d_size = dp.get_parent().rect_size
	dp.rect_min_size = dp_d_size
	dp.rect_size = dp_d_size
	pass

var aligned_zero_focus = false

func _process(_delta):
	if count_label.count <= 1:
		if not aligned_zero_focus:
			get_node(info_desc).grab_focus()
			get_node(info_name).text = ""
			get_node(info_version).text = ""
			get_node(info_priority).text = ""
			get_node(info_mod_id).text = ""
			get_node(info_author).text = ""
			get_node(info_desc_text).text = ""
			get_node(info_desc_author).text = ""
			get_node(info_desc_credits).text = ""
			get_node(info_icon).texture = null
			get_node(info_settings_button).visible = false
			get_node(info_links_button).visible = false
			get_node(info_bugreports_button).visible = false
			aligned_zero_focus = true
	else:
		if aligned_zero_focus:
			var node = get_visible_mods()
			if node.size() >= 1:
				var ar = node[0]
				var tex = StreamTexture.new()
				tex.load_path = "res://HevLib/ui/themes/icons/missing_icon.png.stex"
				if ar["mod_icon"]["has_icon_file"]:
					tex.load_path = ar["mod_icon"]["icon_path"]
				get_node(info_name).text = ar["name"]
				get_node(info_version).text = ar["version_data"]["full_version_string"]
				get_node(info_priority).text = str(ar["priority"])
				get_node(info_mod_id).text = ar["manifest"]["manifest_data"]["mod_information"]["id"]
				get_node(info_author).text = ar["manifest"]["manifest_data"]["mod_information"]["author"]
				get_node(info_desc_text).text = ar["manifest"]["manifest_data"]["mod_information"]["description"]
				get_node(info_desc_author).text = ar["manifest"]["manifest_data"]["mod_information"]["author"]
				var credits = ""
				for c in ar["manifest"]["manifest_data"]["mod_information"]["credits"]:
					if credits == "":
						credits = c
					else:
						credits = credits + "\n" + c
				get_node(info_desc_credits).text = credits
				get_node(info_icon).texture = tex
				get_node(info_settings_button).visible = true
				get_node(info_links_button).visible = true
				get_node(info_bugreports_button).visible = true
			
			aligned_zero_focus = false

var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
var dependancies_store = "user://cache/.Mod_Menu_2_Cache/dependancies/dependancies.json"
var conflicts_store = "user://cache/.Mod_Menu_2_Cache/conflicts/conflicts.json"
var complementary_store = "user://cache/.Mod_Menu_2_Cache/complementary/complementary.json"

var currently_selected_mod_id = ""

var file = File.new()

func get_visible_mods():
	var array = []
	var skip_name = "HEVLIB_NODE_SEPARATOR_IGNORE_PLS"
	var node = get_node("ScrollContainer/VBoxContainer")
	var children = node.get_children()
	for child in children:
		if child.name == skip_name:
			continue
		
		var visibility = child.visible
		if visibility:
			array.append(child.MOD_INFO)
		
	return array

export var conflict_menu_path = NodePath("")
export var dependancy_menu_path = NodePath("")
export var update_menu_path = NodePath("")
onready var conflict_menu = get_node(conflict_menu_path)
onready var dependancy_menu = get_node(dependancy_menu_path)
onready var update_menu = get_node(update_menu_path)

func _open_conflicts():
	var conflicts = ManifestV2.__check_mod_conflicts(currently_selected_mod_id)
	var cfmods = ""
	for mod in conflicts:
		var data = ManifestV2.__get_mod_by_id(mod)
		cfmods = cfmods + "\n" + data["name"] + " (" + data["manifest"]["manifest_data"]["mod_information"]["id"] + ")"
	conflict_menu.dialog_text = TranslationServer.translate("HEVLIB_CONFLICT_INFO_BODY") % cfmods
	conflict_menu.popup()
	var size = Settings.getViewportSize()
	var offset = (size - conflict_menu.rect_size) / 2
	conflict_menu.rect_position = offset
	conflict_menu.rect_size = Vector2(700,450)

func _open_dependancies():
	var conflicts = ManifestV2.__check_mod_dependancies(currently_selected_mod_id)
	var cfmods = ""
	for mod in conflicts:
		var data = ManifestV2.__get_mod_by_id(mod)
		cfmods = cfmods + "\n" + data["name"] + " (" + data["manifest"]["manifest_data"]["mod_information"]["id"] + ")"
	dependancy_menu.dialog_text = TranslationServer.translate("HEVLIB_DEPENDANCY_INFO_BODY") % cfmods
	dependancy_menu.popup()
	var size = Settings.getViewportSize()
	var offset = (size - dependancy_menu.rect_size) / 2
	dependancy_menu.rect_position = offset
	dependancy_menu.rect_size = Vector2(700,450)

func _open_updates():
	file.open(update_store,File.READ)
	var udata = JSON.parse(file.get_as_text()).result
	file.close()
	var tex = TranslationServer.translate("HEVLIB_UPDATE_INFO_BODY") % [str(udata[currently_selected_mod_id]["version"][0]) + "." + str(udata[currently_selected_mod_id]["version"][1]) + "." + str(udata[currently_selected_mod_id]["version"][2]),str(udata[currently_selected_mod_id]["new_version"][0]) + "." + str(udata[currently_selected_mod_id]["new_version"][1]) + "." + str(udata[currently_selected_mod_id]["new_version"][2])]
	update_menu.dialog_text = tex
	update_menu.popup()
	var size = Settings.getViewportSize()
	var offset = (size - update_menu.rect_size) / 2
	update_menu.rect_position = offset
	update_menu.rect_size = Vector2(700,450)
	

var zip_folder = "user://cache/.Mod_Menu_2_Cache/updates/zip_cache/"
const Github = preload("res://HevLib/pointers/Github.gd")
func updates_started():
	file.open(update_store,File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	var github = data[currently_selected_mod_id]["github"]
	var nexus = data[currently_selected_mod_id]["nexus"]
	if github:
		if github.ends_with("/"):
			github.rstrip("/")
		if not github.ends_with("/releases"):
			github = github + "/releases"
		Github.__get_github_release(github,zip_folder,self,true,"zip")
	elif nexus:
		if nexus.ends_with("/"):
			nexus.rstrip("/")
		OS.shell_open(nexus + "?tab=files")
	
	get_node("../../../../../../WAIT").popup_centered()
var has_updated_store = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"






const FileAccess = preload("res://HevLib/pointers/FileAccess.gd")
func _downloaded_zip(file, filepath):
	get_node("../../../../../../WAIT").hide()
	var fi = File.new()
	fi.open(update_store,File.READ)
	var data = JSON.parse(fi.get_as_text()).result
	fi.close()
	
	if currently_selected_mod_id in data:
		data.erase(currently_selected_mod_id)
	fi.open(update_store,File.WRITE)
	fi.store_string(JSON.print(data))
	fi.close()
	fi.open(has_updated_store,File.WRITE)
	fi.store_string("true")
	fi.close()
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	var modPathPrefix = gameInstallDirectory.plus_file("mods")
	subroot.restart_menu.popup_centered()
	FileAccess.__copy_file(filepath,modPathPrefix)
	updates_button.visible = false
