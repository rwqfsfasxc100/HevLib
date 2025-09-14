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
onready var button_label = $ModButton/VBoxContainer/HBoxContainer/Label
onready var button_lib_icon = $ModButton/VBoxContainer/HBoxContainer/VBoxContainer/Library
onready var button_children_icon = $ModButton/VBoxContainer/HBoxContainer/VBoxContainer/Children

onready var brief_box = $BriefInfoLabel

var button_size = Vector2(0,0)

var MAX_SIZE = Vector2(0,0)

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
	tooltip_text = tooltip_text + TranslationServer.translate("HEVLIB_MM_TOOLTIP_MV") % manifest["manifest_version"]
	if ID:
		tooltip_text = tooltip_text + TranslationServer.translate("HEVLIB_MM_TOOLTIP_ID") % ID
	var zip = MOD_INFO["zip"]
	if zip:
		tooltip_text = tooltip_text + TranslationServer.translate("HEVLIB_MM_TOOLTIP_ZIP") % zip
	
	
	
	
	
	
	var showHidden = Settings.HevLib["drivers"]["show_hidden_libraries"]
	if lib_hidden:
		if showHidden:
			visible = true
		else:
			visible = false
	if is_a_library:
		tooltip_text = tooltip_text + TranslationServer.translate("HEVLIB_MM_TOOLTIP_LIBRARY") % [is_a_library,lib_hidden]
	button.hint_tooltip = tooltip_text
	_refocus()

func _input(event):
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("ui_focus_prev"):
		var foc = get_focus_owner()
		var select = ModContainer.get_node("ModInfo/DESC")
		if foc == get_node("ModButton"):
			select.grab_focus()
			get_viewport().set_input_as_handled()

func _visibility_changed():
	MAX_SIZE = Vector2(get_parent().rect_size.x,130) - Vector2(4,0)
#	button_size = MAX_SIZE
#	button_box.rect_size = button_size - Vector2(8,4)
#	button_box.rect_position = Vector2(4,2)
	button_box.rect_size.x = button.rect_size.x - 4
#	button_box2.rect_size.x = button_box.rect_size.x - 4
#	button_label.rect_size.x = button_box2.rect_size.x - 4
	

func _refocus():
	var index = get_parent().get_position_in_parent()
	var parent = get_parent()
	var parent_count = parent.get_child_count()-1
	focus_neighbour_left = get_path_to(self)
	focus_neighbour_right = get_path_to(ModContainer.get_node("ModInfo/DESC"))
	focus_next = get_path_to(ModContainer.get_node("ModInfo/DESC"))
	focus_previous = get_path_to(ModContainer.get_node("ModInfo/DESC"))
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

func _pressed():
	var node = ModContainer.get_node("ModInfo")
	node.selected_mod = self
	node.update()
	if isfocus:
		_change_focus()
	isfocus = true

func _change_focus():
	var node = ModContainer.get_node("ModInfo/DESC")
	node.grab_focus()



func _focus_exited():
	isfocus = false
