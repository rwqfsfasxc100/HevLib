extends Node

static func set_button_focus(button,check_button):
	var parent = button.get_parent()
	var children = parent.get_children()
	var pos = button.get_position_in_parent()
	var icon_button
	var reset_button
	match button.get_script().get_path():
		"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
			icon_button = button.get_node("button/Label/LABELBUTTON")
			reset_button = button.get_node("button/reset")
		_:
			icon_button = button.get_node("Label/LABELBUTTON")
			reset_button = button.get_node("reset")
	
	if children.size() == 1:
		icon_button.focus_neighbour_top = "."
		reset_button.focus_neighbour_top = "."
		check_button.focus_neighbour_top = "."
#		icon_button.focus_neighbour_bottom = "."
#		reset_button.focus_neighbour_bottom = "."
#		check_button.focus_neighbour_bottom = "."
	elif pos == 0:
		icon_button.focus_neighbour_top = "."
		reset_button.focus_neighbour_top = "."
		check_button.focus_neighbour_top = "."
		var script_path = parent.get_child(pos+1).get_script().get_path()
		
		match parent.get_child(pos + 1).get_script().get_path():
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
				icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("button/Label/LABELBUTTON"))
				reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("button/reset"))
			_:
				icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
				reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
		
		match script_path:
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Button"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
				var style = parent.get_child(pos+1).style
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("LineEdit"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("OptionButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
			_:
				breakpoint
	elif pos == children.size() - 1:
		pass
#		icon_button.focus_neighbour_bottom = "."
#		reset_button.focus_neighbour_bottom = "."
#		check_button.focus_neighbour_bottom = "."

		var script_path = parent.get_child(pos-1).get_script().get_path()
		
		match parent.get_child(pos - 1).get_script().get_path():
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
				icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("button/Label/LABELBUTTON"))
				reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("button/reset"))
			_:
				icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
				reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
		match script_path:
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos - 1).get_node("Button"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
				var style = parent.get_child(pos-1).style
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node_or_null(style))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("LineEdit"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("OptionButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
			_:
				breakpoint
	else:
		var script_path = parent.get_child(pos-1).get_script().get_path()
		match parent.get_child(pos - 1).get_script().get_path():
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
				icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("button/Label/LABELBUTTON"))
				reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("button/reset"))
			_:
				icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
				reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
		match script_path:
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos - 1).get_node("Button"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
				var style = parent.get_child(pos-1).style
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node_or_null(style))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("LineEdit"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("OptionButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
			_:
				breakpoint

		var script_path2 = parent.get_child(pos+1).get_script().get_path()
		
		match parent.get_child(pos + 1).get_script().get_path():
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
				icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("button/Label/LABELBUTTON"))
				reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("button/reset"))
			_:
				icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
				reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
		match script_path2:
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Button"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
				var style = parent.get_child(pos+1).style
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("LineEdit"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("OptionButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
			_:
				breakpoint
