extends VBoxContainer

var MOD_INFO = {}

var ModContainer = null

onready var icon_node = $BaseModBox/Icon
onready var icon_conflicts = $BaseModBox/Icon/Control/Conflicts
onready var icon_dependancies = $BaseModBox/Icon/Control/Dependancies
onready var icon_updates = $BaseModBox/Icon/Control/Updates
onready var icon_complementary = $BaseModBox/Icon/Control/Complementary

onready var button = $BaseModBox/ModButton
onready var button_box = $BaseModBox/ModButton/VBoxContainer
onready var button_box2 = $BaseModBox/ModButton/VBoxContainer/HBoxContainer
onready var button_label = $BaseModBox/ModButton/VBoxContainer/HBoxContainer/LABELS/NAME
onready var button_brief = $BaseModBox/ModButton/VBoxContainer/HBoxContainer/LABELS/BRIEF
onready var button_lib_icon = $BaseModBox/ModButton/VBoxContainer/HBoxContainer/VBoxContainer/Library
onready var button_children_icon = $BaseModBox/ModButton/VBoxContainer/HBoxContainer/VBoxContainer/Children
onready var button_children_count = $BaseModBox/ModButton/VBoxContainer/HBoxContainer/VBoxContainer/Children/Count

var ModButton = NodePath("ModButton")
var button_size = Vector2(0,0)

const SubModBox = preload("res://HevLib/ui/mod_menu/mod_list/SubModBox.tscn")

var MAX_SIZE = Vector2(0,0)

var information_nodes = {}

#var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
var pointers
var file = File.new()


var conflicts = []
var dependancies = []
var complementary = []

var already_pressed = false

func _pressed():
	var has_update = false
	var has_dep = false
	var has_conf = false
	var has_links = false
	var has_bugreports = false
	var has_settings = false
	
	
	var manifestData = MOD_INFO["manifest"]["manifest_data"]
	already_pressed = false
	var mod_name = MOD_INFO["name"]
	if information_nodes["info_name"].text == mod_name:
		already_pressed = true
	information_nodes["info_name"].text = mod_name
	var prio = MOD_INFO["priority"]
	if str(prio).ends_with("INF"):
		if str(prio).begins_with("-"):
			prio = "-INF"
		else:
			prio = "INF"
	var ver = MOD_INFO["version_data"]["full_version_string"]
	information_nodes["info_version"].text = TranslationServer.translate("HEVLIB_MODMENU_VERSION") % ver
	information_nodes["info_priority"].text = TranslationServer.translate("HEVLIB_MODMENU_PRIO") % prio
	var tex = StreamTexture.new()
	if MOD_INFO["mod_icon"]["has_icon_file"]:
		tex.load_path = MOD_INFO["mod_icon"]["icon_path"]
	else:
		tex.load_path = "res://HevLib/ui/themes/icons/missing_icon.png.stex"
	information_nodes["info_icon"].texture = tex
	var id = ""
	if manifestData:
		id = manifestData["mod_information"]["id"]
	information_nodes["info_mod_id"].text = id
	var author = ""
	if manifestData:
		author = manifestData["mod_information"]["author"]
	information_nodes["info_author"].parse_bbcode(TranslationServer.translate(author))
	if author != "":
		information_nodes["info_desc_author"].parse_bbcode(TranslationServer.translate(author))
		information_nodes["info_desc_author"].visible = true
	else:
		information_nodes["info_desc_author"].visible = true
	var description = ""
	if manifestData:
		description = manifestData["mod_information"]["description"]
	information_nodes["info_desc_text"].parse_bbcode(TranslationServer.translate(description))
	var creditText = ""
	if manifestData:
		for item in manifestData["mod_information"]["credits"]:
			if creditText == "":
				creditText = item
			else:
				creditText = creditText + "\n" + item
	if creditText != "":
		information_nodes["info_desc_credits"].parse_bbcode(TranslationServer.translate(creditText))
		information_nodes["info_desc_credits"].visible = true
	else:
		information_nodes["info_desc_credits"].visible = false
		
	var default_URL_icon = "res://HevLib/ui/themes/icons/alias.stex"
	information_nodes["links_menu_path"].MOD_INFO = MOD_INFO
	information_nodes["links_menu_path"].update()
	if manifestData:
		var links = manifestData["links"]
		var configs = manifestData["configs"]
		var link_size = links.size()
		var config_size = configs.size()
		if link_size == 0:
			information_nodes["info_links_button"].visible = false
			information_nodes["info_bugreports_button"].visible = false
			information_nodes["info_bugreports_button"].url = ""
		else:
			
			if "HEVLIB_BUGREPORTS" in links:
				has_bugreports = true
				information_nodes["info_bugreports_button"].visible = true
				information_nodes["info_bugreports_button"].url = links["HEVLIB_BUGREPORTS"].get("URL","")
			else:
				information_nodes["info_bugreports_button"].visible = false
			if link_size == 1 and has_bugreports:
				information_nodes["info_links_button"].visible = false
			else:
				information_nodes["info_links_button"].visible = true
				has_links = true
		
		if config_size == 0:
			information_nodes["info_settings_button"].visible = false
		else:
			has_settings = true
			information_nodes["info_settings_button"].visible = true
			information_nodes["settings_menu"].SELECTED_MOD = mod_name
			information_nodes["settings_menu"].SELECTED_MOD_ID = id
		var changelog = manifestData["manifest_definitions"].get("changelog_path","")
		if changelog != "":
			var path = MOD_INFO["node"].get_script().get_path()
			var modpath = path.split(path.split("/")[path.split("/").size() - 1])[0]
			var c = modpath + changelog
			if file.file_exists(c):
				information_nodes["info_changelog_button"].visible = true
				information_nodes["changelog_menu"].update_this(c)
			else:
				information_nodes["info_changelog_button"].visible = false
				information_nodes["changelog_menu"].clear()
		else:
			information_nodes["info_changelog_button"].visible = false
			information_nodes["changelog_menu"].clear()
		
	else:
		information_nodes["info_settings_button"].visible = false
		information_nodes["info_links_button"].visible = false
		information_nodes["info_bugreports_button"].visible = false
		information_nodes["info_changelog_button"].visible = false
		information_nodes["changelog_menu"].clear()
	if already_pressed:
		if get_child_count() >= 2:
			for i in range(1,get_child_count()):
				var node = get_child(i)
				node.visible = !node.visible
	information_nodes["mod_list"].currently_selected_mod_id = ID
	file.open(update_store,File.READ)
	var update_data = JSON.parse(file.get_as_text()).result
	file.close()
	file.open(conflicts_store,File.READ)
	var conflict_data = JSON.parse(file.get_as_text()).result
	file.close()
	file.open(dependancies_store,File.READ)
	var dependancy_data = JSON.parse(file.get_as_text()).result
	file.close()
	
	
	
	if id in update_data:
		information_nodes["updates_button"].visible = true
		information_nodes["updates_button"].hint_tooltip = TranslationServer.translate("HEVLIB_ICON_TOOLTIP_UPDATES") % [str(update_data[ID]["version"][0])+"."+str(update_data[ID]["version"][1])+"."+str(update_data[ID]["version"][2]),str(update_data[ID]["new_version"][0])+"."+str(update_data[ID]["new_version"][1])+"."+str(update_data[ID]["new_version"][2])]
		has_update = true
	else:
		information_nodes["updates_button"].visible = false
		
	
	if id in dependancy_data:
		information_nodes["dependancies_button"].visible = true
		var cd = ""
		for i in dependancy_data[id]:
			var mname = pointers.ManifestV2.__get_mod_by_id(i)["name"]
			cd = cd + "\n" + mname
		information_nodes["dependancies_button"].hint_tooltip = TranslationServer.translate("HEVLIB_ICON_TOOLTIP_DEPENDANCIES") % cd
		has_dep = true
	else:
		information_nodes["dependancies_button"].visible = false
		
	if id in conflict_data:
		information_nodes["conflict_button"].visible = true
		var cd = ""
		for i in conflict_data[id]:
			var mname = pointers.ManifestV2.__get_mod_by_id(i)["name"]
			cd = cd + "\n" + mname
		information_nodes["conflict_button"].hint_tooltip = TranslationServer.translate("HEVLIB_ICON_TOOLTIP_CONFLICT") % cd
		has_conf = true
	else:
		information_nodes["conflict_button"].visible = false
	if has_links:
		information_nodes["info_desc"].focus_neighbour_top = NodePath("../LINKBOX/LINKS")
	elif has_bugreports:
		information_nodes["info_desc"].focus_neighbour_top = NodePath("../LINKBOX/BUGREPORTS")
	elif has_settings:
		information_nodes["info_desc"].focus_neighbour_top = NodePath("../Header/SETTINGS")
	else:
		information_nodes["info_desc"].focus_neighbour_top = NodePath("../../SPLIT/ListHeader/SearchBox/FILTER")
		
#	information_nodes["info_desc"].focus_neighbour_top = NodePath("")
	
	if has_update:
		information_nodes["info_desc"].focus_neighbour_top = NodePath("../WarningButtons/UB")
	elif has_dep:
		information_nodes["info_desc"].focus_neighbour_top = NodePath("../WarningButtons/DB")
	elif has_conf:
		information_nodes["info_desc"].focus_neighbour_top = NodePath("../WarningButtons/CFB")
	
	

var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
var dependancies_store = "user://cache/.Mod_Menu_2_Cache/dependancies/dependancies.json"
var conflicts_store = "user://cache/.Mod_Menu_2_Cache/conflicts/conflicts.json"
var complementary_store = "user://cache/.Mod_Menu_2_Cache/complementary/complementary.json"




#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")


var children = {}
func _ready():
	if "children" in MOD_INFO.keys():
		children = MOD_INFO["children"]
	
	for i in children:
		var pdata = children[i]
		var panel = SubModBox.instance()
		var pname = pdata["name"]
		if pdata["mod_icon"]["has_icon_file"]:
			var tex = StreamTexture.new()
			tex.load_path = pdata["mod_icon"]["icon_path"]
			panel.get_node("Icon").texture = tex
		panel.get_node("ModButton/VBoxContainer/HBoxContainer/LABELS/NAME").text = pname
		if pdata["manifest"]["has_manifest"]:
			panel.get_node("ModButton/VBoxContainer/HBoxContainer/LABELS/BRIEF").text = pdata["manifest"]["manifest_data"]["mod_information"]["brief"]
		else:
			panel.get_node("ModButton/VBoxContainer/HBoxContainer/LABELS/BRIEF").text = ""
		panel.name = pname
		panel.visible = false
		add_child(panel)
#		breakpoint
	


var ID = null

func _draw():
	MAX_SIZE = Vector2(get_parent().rect_size.x,130) - Vector2(4,0)
	
	button_lib_icon.visible = false
	button_children_icon.visible = false
	icon_complementary.visible = false
	icon_conflicts.visible = false
	icon_dependancies.visible = false
	icon_updates.visible = false
	
	
	file.open(update_store,File.READ)
	var updt = JSON.parse(file.get_as_text()).result
	file.close()
	file.open(conflicts_store,File.READ)
	var conf = JSON.parse(file.get_as_text()).result
	file.close()
	file.open(dependancies_store,File.READ)
	var dep = JSON.parse(file.get_as_text()).result
	file.close()
	file.open(complementary_store,File.READ)
	var comp = JSON.parse(file.get_as_text()).result
	file.close()
	
	
	if ID in updt:
		icon_updates.visible = true
		icon_updates.hint_tooltip = TranslationServer.translate("HEVLIB_ICON_TOOLTIP_UPDATES") % [str(updt[ID]["version"][0])+"."+str(updt[ID]["version"][1])+"."+str(updt[ID]["version"][2]),str(updt[ID]["new_version"][0])+"."+str(updt[ID]["new_version"][1])+"."+str(updt[ID]["new_version"][2])]
	else:
		icon_updates.visible = false
	if ID in conf:
		icon_conflicts.visible = true
		var cd = ""
		for i in conf[ID]:
			var mname = pointers.ManifestV2.__get_mod_by_id(i)["name"]
			cd = cd + "\n" + mname
		icon_conflicts.hint_tooltip = TranslationServer.translate("HEVLIB_ICON_TOOLTIP_CONFLICT") % cd
	else:
		icon_conflicts.visible = false
	if ID in dep:
		icon_dependancies.visible = true
		var cd = ""
		for i in dep[ID]:
			var mname = pointers.ManifestV2.__get_mod_by_id(i)["name"]
			cd = cd + "\n" + mname
		icon_dependancies.hint_tooltip = TranslationServer.translate("HEVLIB_ICON_TOOLTIP_DEPENDANCIES") % cd
	else:
		icon_dependancies.visible = false
	if ID in comp:
		icon_complementary.visible = true
		var cd = ""
		for i in comp[ID]:
			var mname = pointers.ManifestV2.__get_mod_by_id(i)["name"]
			cd = cd + "\n" + mname
		icon_complementary.hint_tooltip = TranslationServer.translate("HEVLIB_ICON_TOOLTIP_COMPLEMENTARY") % cd
	else:
		icon_complementary.visible = false
	
	
	button_box.rect_size.x = button.rect_size.x - 4
	
	var mod_name = MOD_INFO["name"]
	var prio = MOD_INFO["priority"]
	if str(prio).ends_with("INF"):
		if str(prio).begins_with("-"):
			prio = "-INF"
		else:
			prio = "INF"
	var version_arr = MOD_INFO["version_data"]["full_version_array"]
	var version_print = MOD_INFO["version_data"]["full_version_string"]
	var icon = ""
	if MOD_INFO["mod_icon"]["has_icon_file"]:
		icon = MOD_INFO["mod_icon"]["icon_path"]
	var is_library = MOD_INFO["library_information"]["is_library"]
	var always_display = false
	if is_library:
		always_display = MOD_INFO["library_information"]["always_display"]
	var manifest = MOD_INFO["manifest"]
	if is_library:
		button_lib_icon.visible = true
	button_label.text = mod_name
	if icon != "":
		var tex = StreamTexture.new()
		tex.load_path = icon
		icon_node.texture = tex
	var tooltip_text = TranslationServer.translate("HEVLIB_MM_TOOLTIP_HEADER")

	var md = manifest["manifest_data"]
	if md:
		ID = md["mod_information"]["id"]
		
	tooltip_text = tooltip_text + "\n" + TranslationServer.translate("HEVLIB_MM_TOOLTIP_MV") % manifest["manifest_version"]
	if ID:
		tooltip_text = tooltip_text + "\n" + TranslationServer.translate("HEVLIB_MM_TOOLTIP_ID") % ID
		if ID == "kodera.vanilla":
			var tex = StreamTexture.new()
			tex.load_path = "res://HevLib/ui/mod_menu/vanilla/kodera.stex"
			button_lib_icon.texture = tex
			button_lib_icon.modulate = Color(1,1,1,1)
			button_lib_icon.visible = true
	var zip = MOD_INFO["zip"]
	if zip:
		tooltip_text = tooltip_text + "\n" + TranslationServer.translate("HEVLIB_MM_TOOLTIP_ZIP") % zip
	
	var manifestData = MOD_INFO["manifest"]["manifest_data"]
	var brief = ""
	if manifestData:
		brief = manifestData["mod_information"]["brief"]
	button_brief.text = brief
	getPointers()
	
	
	var showHidden = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_hidden_libraries")
	if is_library:
		if showHidden or always_display:
			visible = true
		else:
			visible = false
	
	
	if is_library:
		tooltip_text = tooltip_text + "\n" + TranslationServer.translate("HEVLIB_MM_TOOLTIP_LIBRARY") % [is_library,always_display]
	button.hint_tooltip = tooltip_text
	
	if is_visible_in_tree():
		var pos = get_position_in_parent()
		if pos == 0:
			button.grab_focus()
	
	if children:
		button_children_icon.visible = true
		button_children_count.visible = true
		button_children_count.text = "%s" % children.size()
		
		handle_sub_mods()
	
	
	
	
	
#	conflicts = ManifestV2.__check_mod_conflicts(ID)
#	dependancies = ManifestV2.__check_mod_dependancies(ID)
#	complementary = ManifestV2.__check_mod_complementary(ID)
#	if conflicts:
#		$Icon/Control/Conflicts.visible = true
#	if dependancies:
#		$Icon/Control/Dependancies.visible = true
#	if complementary:
#		$Icon/Control/Complementary.visible = true
	
	
	
#	_refocus()
var descbox = "../ModInfo/DESC"
func _input(event):
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("ui_focus_prev"):
		var foc = get_focus_owner()
		var select = ModContainer.get_node(descbox)
		if foc == button:
			select.grab_focus()
			get_viewport().set_input_as_handled()

onready var desc_box = ModContainer.get_node(descbox)
#func _process(_delta):
#	if is_visible_in_tree():
#		MAX_SIZE = Vector2(get_parent().rect_size.x,130) - Vector2(4,0)
#		button_box.rect_size.x = button.rect_size.x - 4
		
		

func get_button(pos):
	return get_parent().get_child(pos).get_node("BaseModBox/ModButton")

func _refocus():
	MAX_SIZE = Vector2(get_parent().rect_size.x,130) - Vector2(4,0)
	button_box.rect_size.x = button.rect_size.x - 4
	var index = get_parent().get_position_in_parent()
	var parent = get_parent()
	var parent_count = parent.get_child_count()-1
	
	
	var upper = null
	var lower = null
	var mb = button.get_path_to(button)
	button.focus_neighbour_left = mb
	button.focus_neighbour_right = button.get_path_to(desc_box)
	button.focus_next = button.get_path_to(desc_box)
	button.focus_previous = button.get_path_to(desc_box)
	
	
	var pos = get_position_in_parent()
	var end_pos = get_parent().get_node("HEVLIB_NODE_SEPARATOR_IGNORE_PLS").get_position_in_parent()
	
	if pos == 0:
#		button.focus_neighbour_top = mb
		button.focus_neighbour_top = button.get_path_to(filter_button)
		button.focus_neighbour_bottom = button.get_path_to(get_button(pos+1))
	elif pos + 1 == end_pos:
		button.focus_neighbour_top = button.get_path_to(get_button(pos-1))
		button.focus_neighbour_bottom = button.get_path_to(get_node(openMods_button))
		get_node(openMods_button).focus_neighbour_top = get_node(openMods_button).get_path_to(button)
	else:
		button.focus_neighbour_top = button.get_path_to(get_button(pos-1))
		button.focus_neighbour_bottom = button.get_path_to(get_button(pos+1))
	
	
var isfocus = false


var filter_button_path = "../../../../ListHeader/SearchBox/FILTER"
onready var filter_button = get_node(filter_button_path)
var openMods_button = "../../../../../../FooterButtons/OpenFolder"

var mod_menu_panel_path = "../../../../../../../../.."
onready var mod_menu_panel = get_node(mod_menu_panel_path)

var filterContainerPath = mod_menu_panel_path + "/FilterPopup/base/FilterContainer"
onready var filter_container = get_node(filterContainerPath)

var cache_folder = "user://cache/.Mod_Menu_2_Cache/"
var filter_cache_file = "menu_filter_cache.json"

func _process(_delta):
	handle_sub_mods()
	if mod_menu_panel and mod_menu_panel.visible:
		var manifestData = MOD_INFO["manifest"]["manifest_data"]
		var check_against = MOD_INFO["name"].to_upper()
		var id_against = ""
		if manifestData:
			id_against = manifestData["mod_information"]["id"].to_upper()
		var current_selection = filter_button.keys_pressed
		if pointers == null:
			getPointers()
			
		if all_tags:
			file.open(cache_folder + filter_cache_file,File.READ)
			var filter_data = JSON.parse(file.get_as_text()).result
			file.close()
			if filter_data.size() >= 1:
				var tag_visible = false
				for tag in all_tags:
					if not tag in filter_data:
						var tag_mods = all_tags[tag]
						for md in tag_mods:
							if md.to_upper() == id_against:
								tag_visible = true
	#					breakpoint
	#			breakpoint
				visible = tag_visible
			else:
				visible = true
			if visible:
				if current_selection and current_selection != "":
					var i = check_against.countn(current_selection)
					var f = id_against.countn(current_selection)
					if i or f:
						visible = true
					else:
						visible = false
				else:
					visible = true
	var btnResize = Vector2($BaseModBox.rect_size.x - $BaseModBox/ModButton.rect_position.x,$BaseModBox.rect_size.y)
	$BaseModBox/ModButton.rect_size = btnResize
	button_box.rect_size.x = button.rect_size.x - 4

func _visibility_changed():
	MAX_SIZE = Vector2(get_parent().rect_size.x,130) - Vector2(4,0)
	button_box.rect_size.x = button.rect_size.x - 4
	_refocus()
	handle_sub_mods()
#	button.focus_neighbor_top = get_path_to(upper)
#	button.focus_neighbor_bottom = get_path_to(lower)
	if is_visible_in_tree():
		if get_position_in_parent() == 0:
			
			button.grab_focus()

func handle_sub_mods():
	var panels = get_child_count()
	if panels >= 2:
		for i in range(1,panels):
			var panel = get_child(i)
			if panel.visible:
#				panel.rect_pivot_offset = Vector2(panel.rect_size.x / 2,panel.rect_size.y / 2)
#				panel.rect_scale = Vector2(0.5,0.5)
#				if i == panels - 1:
#					panel.get_node("Label/Line2D").points.size(3)
				
				panel.get_node("ModButton/VBoxContainer").rect_size.x = panel.get_node("ModButton").rect_size.x - 4
#				breakpoint
	
var all_tags
func getPointers():
	pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	all_tags = pointers.ManifestV2.__get_tags()
	pass
