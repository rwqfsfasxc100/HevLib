extends Node

const SAVE_BUTTONS = [
	{
		"display_name":"CONFIRM_OVERRIDE_GAME",
		"popup_path":null,
		"popup_override":"POPUP_ROOT", # "POPUP_ROOT" for menu root node, "SAVE_BUTTON" for obv save button
		"connect_method":"_on_DELETE_SAVE_pressed",
		"enable_on_save":true,
	},
#	{
#		"display_name":"TEST",
#		"popup_path":"res://HevLib/scenes/better_title_screen/example/example.tscn",
#		"connect_method":"_pressed",
#		"enable_on_save":true,
#		"send_additional_info":true
#	},
]
