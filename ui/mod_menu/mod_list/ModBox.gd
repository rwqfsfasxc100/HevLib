extends HBoxContainer

var MOD_INFO = {}

var ModContainer = null

onready var icon_node = $Icon
onready var icon_conflicts = $Icon/Control/Conflicts
onready var icon_dependancies = $Icon/Control/Dependancies
onready var icon_updates = $Icon/Control/Updates
onready var icon_complementary = $Icon/Control/Complementary

onready var button = $ModButton
onready var button_box = $ModButton/VBoxContainer
onready var button_box2 = $ModButton/VBoxContainer/HBoxContainer
onready var button_label = $ModButton/VBoxContainer/HBoxContainer/LABELS/NAME
onready var button_brief = $ModButton/VBoxContainer/HBoxContainer/LABELS/BRIEF
onready var button_lib_icon = $ModButton/VBoxContainer/HBoxContainer/VBoxContainer/Library
onready var button_children_icon = $ModButton/VBoxContainer/HBoxContainer/VBoxContainer/Children
onready var button_children_count = $ModButton/VBoxContainer/HBoxContainer/VBoxContainer/Children/Count

var button_size = Vector2(0,0)

var MAX_SIZE = Vector2(0,0)

var information_nodes = {}

var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

onready var all_tags = ManifestV2.__get_tags()

func _pressed():
	var manifestData = MOD_INFO["manifest"]["manifest_data"]
	var mod_name = MOD_INFO["name"]
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
	if MOD_INFO["mod_icon"]["has_icon_file"]:
		var tex = StreamTexture.new()
		tex.load_path = MOD_INFO["mod_icon"]["icon_path"]
		information_nodes["info_icon"].texture = tex
	var id = ""
	if manifestData:
		id = manifestData["mod_information"]["id"]
	information_nodes["info_mod_id"].text = id
	var author = ""
	if manifestData:
		author = manifestData["mod_information"]["author"]
	information_nodes["info_author"].text = author
	information_nodes["info_desc_author"].text = author
	var description = ""
	if manifestData:
		description = manifestData["mod_information"]["description"]
	information_nodes["info_desc_text"].text = description
	var creditText = ""
	if manifestData:
		for item in manifestData["mod_information"]["credits"]:
			if creditText == "":
				creditText = item
			else:
				creditText = creditText + "\n" + item
	information_nodes["info_desc_credits"].text = creditText
	
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
			var has_bug_reports = false
			if "HEVLIB_BUGREPORTS" in links:
				has_bug_reports = true
				information_nodes["info_bugreports_button"].visible = true
				information_nodes["info_bugreports_button"].url = links["HEVLIB_BUGREPORTS"].get("URL","")
			else:
				information_nodes["info_bugreports_button"].visible = false
			if link_size == 1 and has_bug_reports:
				information_nodes["info_links_button"].visible = false
			else:
				information_nodes["info_links_button"].visible = true
		
		if config_size == 0:
			information_nodes["info_settings_button"].visible = false
		else:
			information_nodes["info_settings_button"].visible = true
			information_nodes["settings_menu"].SELECTED_MOD = mod_name
			information_nodes["settings_menu"].SELECTED_MOD_ID = id
		
	else:
		information_nodes["info_settings_button"].visible = false
		information_nodes["info_links_button"].visible = false
		information_nodes["info_bugreports_button"].visible = false



const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")







func _draw():
	MAX_SIZE = Vector2(get_parent().rect_size.x,130) - Vector2(4,0)
	
	button_lib_icon.visible = false
	button_children_icon.visible = false
	icon_complementary.visible = false
	icon_conflicts.visible = false
	icon_dependancies.visible = false
	icon_updates.visible = false
	
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
	var children = {}
	if "children" in MOD_INFO.keys():
		children = MOD_INFO["children"]
	if is_library:
		button_lib_icon.visible = true
	button_label.text = mod_name
	if icon != "":
		var tex = StreamTexture.new()
		tex.load_path = icon
		icon_node.texture = tex
	var tooltip_text = TranslationServer.translate("HEVLIB_MM_TOOLTIP_HEADER")
	var ID = null
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
	
	
	
	var showHidden = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_hidden_libraries")
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
	
	
	
#	_refocus()
var descbox = "../ModInfo/DESC"

func _input(event):
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("ui_focus_prev"):
		var foc = get_focus_owner()
		var select = ModContainer.get_node(descbox)
		if foc == get_node("ModButton"):
			select.grab_focus()
			get_viewport().set_input_as_handled()

onready var desc_box = ModContainer.get_node(descbox)
onready var mod_box = get_node("ModButton")
#func _process(_delta):
#	if is_visible_in_tree():
#		MAX_SIZE = Vector2(get_parent().rect_size.x,130) - Vector2(4,0)
#		button_box.rect_size.x = button.rect_size.x - 4
		
		

func get_button(pos):
	return get_parent().get_child(pos).get_node("ModButton")

func _refocus():
	MAX_SIZE = Vector2(get_parent().rect_size.x,130) - Vector2(4,0)
	button_box.rect_size.x = button.rect_size.x - 4
	var index = get_parent().get_position_in_parent()
	var parent = get_parent()
	var parent_count = parent.get_child_count()-1
	focus_neighbour_left = get_path_to(self)
	focus_neighbour_right = get_path_to(ModContainer.get_node(descbox))
	focus_next = get_path_to(ModContainer.get_node(descbox))
	focus_previous = get_path_to(ModContainer.get_node(descbox))
#	breakpoint
	if index == 0:
#		focus_neighbour_top = get_path_to(self)
		focus_neighbour_top = mod_box.get_path_to(filter_button)
		focus_neighbour_bottom = get_path_to(parent.get_child(index+1).get_node("ModButton"))
	elif index == parent_count:
		focus_neighbour_top = get_path_to(parent.get_child(index-1).get_node("ModButton"))
		focus_neighbour_bottom = get_path_to(self)
	else:
		focus_neighbour_top = get_path_to(parent.get_child(index-1).get_node("ModButton"))
		focus_neighbour_bottom = get_path_to(parent.get_child(index+1).get_node("ModButton"))
	
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
	if mod_menu_panel and mod_menu_panel.visible:
		var manifestData = MOD_INFO["manifest"]["manifest_data"]
		var check_against = MOD_INFO["name"].to_upper()
		var id_against = ""
		if manifestData:
			id_against = manifestData["mod_information"]["id"].to_upper()
		var current_selection = filter_button.keys_pressed
		
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
var file = File.new()
func _visibility_changed():
	MAX_SIZE = Vector2(get_parent().rect_size.x,130) - Vector2(4,0)
	button_box.rect_size.x = button.rect_size.x - 4
	var pos = get_position_in_parent()
	var parent = get_parent()
	var end_pos = get_parent().get_node("HEVLIB_NODE_SEPARATOR_IGNORE_PLS").get_position_in_parent()
	
	var upper = null
	var lower = null
	var mb = mod_box.get_path_to(mod_box)
	mod_box.focus_neighbour_left = mb
	mod_box.focus_neighbour_right = mod_box.get_path_to(desc_box)
	mod_box.focus_next = mod_box.get_path_to(desc_box)
	mod_box.focus_previous = mod_box.get_path_to(desc_box)
	
	if pos == 0:
#		mod_box.focus_neighbour_top = mb
		mod_box.focus_neighbour_top = mod_box.get_path_to(filter_button)
		mod_box.focus_neighbour_bottom = mod_box.get_path_to(get_button(pos+1))
	elif pos + 1 == end_pos:
		mod_box.focus_neighbour_top = mod_box.get_path_to(get_button(pos-1))
		mod_box.focus_neighbour_bottom = mod_box.get_path_to(get_node(openMods_button))
		get_node(openMods_button).focus_neighbour_top = get_node(openMods_button).get_path_to(mod_box)
	else:
		mod_box.focus_neighbour_top = mod_box.get_path_to(get_button(pos-1))
		mod_box.focus_neighbour_bottom = mod_box.get_path_to(get_button(pos+1))
#	mod_box.focus_neighbor_top = get_path_to(upper)
#	mod_box.focus_neighbor_bottom = get_path_to(lower)
	if is_visible_in_tree():
		if pos == 0:
			
			button.grab_focus()
