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

onready var brief_box = $BriefInfoLabel

var button_size = Vector2(0,0)

var MAX_SIZE = Vector2(0,0)

var information_nodes = {}

func _pressed():
	
	information_nodes["info_name"].text = MOD_INFO["name"]
	var prio = MOD_INFO["priority"]
	var ver = MOD_INFO["version_data"]["full_version_string"]
	information_nodes["info_version"].text = TranslationServer.translate("HEVLIB_MODMENU_VERSION") % ver
	information_nodes["info_priority"].text = TranslationServer.translate("HEVLIB_MODMENU_PRIO") % prio
	if MOD_INFO["mod_icon"]["has_icon_file"]:
		var tex = StreamTexture.new()
		tex.load_path = MOD_INFO["mod_icon"]["icon_path"]
		information_nodes["info_icon"].texture = tex
	information_nodes["info_mod_id"].text = MOD_INFO["manifest"]["manifest_data"]["mod_information"]["id"]
	information_nodes["info_author"].text = MOD_INFO["manifest"]["manifest_data"]["mod_information"]["author"]
	information_nodes["info_desc_author"].text = MOD_INFO["manifest"]["manifest_data"]["mod_information"]["author"]
	information_nodes["info_desc_text"].text = MOD_INFO["manifest"]["manifest_data"]["mod_information"]["description"]
	var creditText = ""
	for item in MOD_INFO["manifest"]["manifest_data"]["mod_information"]["credits"]:
		if creditText == "":
			creditText = item
		else:
			creditText = creditText + "\n" + item
	information_nodes["info_desc_credits"].text = creditText
	
#	breakpoint












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
	var version_arr = MOD_INFO["version_data"]["full_version_array"]
	var version_print = MOD_INFO["version_data"]["full_version_string"]
	var icon = ""
	if MOD_INFO["mod_icon"]["has_icon_file"]:
		icon = MOD_INFO["mod_icon"]["icon_path"]
	var is_a_library = MOD_INFO["library_information"]["is_a_library"]
	var lib_hidden = true
	if is_a_library:
		lib_hidden = MOD_INFO["library_information"]["keep_library_hidden"]
	var manifest = MOD_INFO["manifest"]
	var children = {}
	if "children" in MOD_INFO.keys():
		children = MOD_INFO["children"]
	if is_a_library:
		button_lib_icon.visible = true
	else:
		lib_hidden = false
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
	var zip = MOD_INFO["zip"]
	if zip:
		tooltip_text = tooltip_text + "\n" + TranslationServer.translate("HEVLIB_MM_TOOLTIP_ZIP") % zip
	
	
	button_brief.text = MOD_INFO["manifest"]["manifest_data"]["mod_information"]["brief"]
	
	
	
	var showHidden = Settings.HevLib["drivers"]["show_hidden_libraries"]
	if lib_hidden:
		if showHidden:
			visible = true
		else:
			visible = false
	if is_a_library:
		tooltip_text = tooltip_text + "\n" + TranslationServer.translate("HEVLIB_MM_TOOLTIP_LIBRARY") % [is_a_library,lib_hidden]
	button.hint_tooltip = tooltip_text
	
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
		mod_box.focus_neighbour_top = mb
		mod_box.focus_neighbour_bottom = mod_box.get_path_to(get_button(pos+1))
	elif pos + 1 == end_pos:
		mod_box.focus_neighbour_top = mod_box.get_path_to(get_button(pos-1))
		mod_box.focus_neighbour_bottom = mb
	else:
		mod_box.focus_neighbour_top = mod_box.get_path_to(get_button(pos-1))
		mod_box.focus_neighbour_bottom = mod_box.get_path_to(get_button(pos+1))
#	mod_box.focus_neighbor_top = get_path_to(upper)
#	mod_box.focus_neighbor_bottom = get_path_to(lower)
	if is_visible_in_tree():
		if pos == 0:
			
			button.grab_focus()

func get_button(pos):
	return get_parent().get_child(pos).get_node("ModButton")

func _refocus():
	var index = get_parent().get_position_in_parent()
	var parent = get_parent()
	var parent_count = parent.get_child_count()-1
	focus_neighbour_left = get_path_to(self)
	focus_neighbour_right = get_path_to(ModContainer.get_node(descbox))
	focus_next = get_path_to(ModContainer.get_node(descbox))
	focus_previous = get_path_to(ModContainer.get_node(descbox))
#	breakpoint
	if index == 0:
		focus_neighbour_top = get_path_to(self)
		focus_neighbour_bottom = get_path_to(parent.get_child(index+1).get_node("ModButton"))
	elif index == parent_count:
		focus_neighbour_top = get_path_to(parent.get_child(index-1).get_node("ModButton"))
		focus_neighbour_bottom = get_path_to(self)
	else:
		focus_neighbour_top = get_path_to(parent.get_child(index-1).get_node("ModButton"))
		focus_neighbour_bottom = get_path_to(parent.get_child(index+1).get_node("ModButton"))
	
var isfocus = false


