extends Node

static func set_button_focus(button,check_button):
	var parent = button.get_parent()
	var children = parent.get_children()
	var pos = button.get_position_in_parent()
	var icon_button = button.get_node("Label/LABELBUTTON")
	var reset_button = button.get_node("reset")
	if children.size() == 1:
		icon_button.focus_neighbour_top = "."
		reset_button.focus_neighbour_top = "."
		check_button.focus_neighbour_top = "."
		icon_button.focus_neighbour_bottom = "."
		reset_button.focus_neighbour_bottom = "."
		check_button.focus_neighbour_bottom = "."
		icon_button.grab_focus()
	elif pos == 0:
		icon_button.focus_neighbour_top = "."
		reset_button.focus_neighbour_top = "."
		check_button.focus_neighbour_top = "."
		icon_button.grab_focus()
		var script_path = parent.get_child(pos+1).get_script().get_path()
		icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
		reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
		match script_path:
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
				var style = parent.get_child(pos+1).style
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
			_:
				breakpoint
	elif pos == children.size() - 1:
		icon_button.focus_neighbour_bottom = "."
		reset_button.focus_neighbour_bottom = "."
		check_button.focus_neighbour_bottom = "."

		var script_path = parent.get_child(pos-1).get_script().get_path()
		icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
		reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
		match script_path:
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
				var style = parent.get_child(pos+1).style
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
			_:
				breakpoint
	else:
		var script_path = parent.get_child(pos-1).get_script().get_path()
		icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
		reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
		match script_path:
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
				check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
				var style = parent.get_child(pos+1).style
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
			_:
				breakpoint

		var script_path2 = parent.get_child(pos+1).get_script().get_path()
		icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
		reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
		match script_path2:
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
				var style = parent.get_child(pos+1).style
				check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
			_:
				breakpoint
