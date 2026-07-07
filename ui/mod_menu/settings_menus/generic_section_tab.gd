extends Tabs

var section_info = {}

var section_values = {}

var mod = ""

func _draw():
	$MarginContainer.rect_size = rect_size
	$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.rect_min_size = $MarginContainer.rect_size
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _ready():
	var ordered_section_info:Dictionary = {}
	var orderof = {}
	var reorder = []
	for entry in section_info:
		var secentry = section_info[entry]
		if "display_order_position" in secentry:
			var pos = secentry.display_order_position
			while pos in orderof:
				pos += 1
			orderof[pos] = [entry,secentry]
		else:
			reorder.append([entry,secentry])
	var ctr = 0
	for i in orderof:
		if i > ctr:
			ctr = i
	for i in reorder:
		ctr += 1
		orderof[ctr] = i
	var orderKeys = orderof.keys()
	orderKeys.sort()
	for r in orderKeys:
		var i = orderof[r]
		ordered_section_info[i[0]] = i[1]
	for entry in ordered_section_info:
		var entry_info = ordered_section_info[entry]
		var entry_values = section_values[entry]
		
		var type = entry_info["type"].to_lower()
		match type:
			"bool","boolean":
				var input = BOOL.instance()
				input.name = entry
				input.CONFIG_DATA = entry_info
				input.CONFIG_ENTRY = entry
				input.CONFIG_SECTION = name
				input.CONFIG_MOD = mod
				$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(input)
			"float","int","integer","real":
				var input = INT_FLOAT.instance()
				input.name = entry
				input.CONFIG_DATA = entry_info
				input.CONFIG_ENTRY = entry
				input.CONFIG_SECTION = name
				input.CONFIG_MOD = mod
				match type:
					"int","integer":
						input.val_type = "int"
					"float","real":
						input.val_type = "float"
				$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(input)
			"string","str":
				var input = STRING.instance()
				input.name = entry
				input.CONFIG_DATA = entry_info
				input.CONFIG_ENTRY = entry
				input.CONFIG_SECTION = name
				input.CONFIG_MOD = mod
				$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(input)
			"option","optionbutton","option_button":
				var input = OPTION.instance()
				input.name = entry
				input.CONFIG_DATA = entry_info
				input.CONFIG_ENTRY = entry
				input.CONFIG_SECTION = name
				input.CONFIG_MOD = mod
				$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(input)
			"input":
				var input = INPUT.instance()
				input.name = entry
				input.CONFIG_DATA = entry_info
				input.CONFIG_ENTRY = entry
				input.CONFIG_SECTION = name
				input.CONFIG_MOD = mod
				$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(input)
			"action":
				var input = ACTION.instance()
				input.name = entry
				input.CONFIG_DATA = entry_info
				input.CONFIG_ENTRY = entry
				input.CONFIG_SECTION = name
				input.CONFIG_MOD = mod
				$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(input)
		
		yield(get_tree(),"idle_frame")
	var hb = HBoxContainer.new()
	hb.name = "BottomSeparatorForToolTipsPlsIgnore"
	hb.set_script(load("res://HevLib/ui/mod_menu/mod_list/BottomSeparator.gd"))
	hb.connect("visibility_changed",hb,"_visibility_changed")
	$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(hb)
#	breakpoint



const BOOL = preload("res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.tscn")
const INT_FLOAT = preload("res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.tscn")
const STRING = preload("res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.tscn")
const OPTION = preload("res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.tscn")
const INPUT = preload("res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.tscn")
const ACTION = preload("res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.tscn")


func cancel():
	get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().cancel()
