extends Node

const SAVE_BUTTONS = [
	{
		"display_name":"HEVLIB_SAVEOPT_FIX_CORRUPTED_CARGO",
		"popup_path":"res://HevLib/scenes/better_title_screen/FixSaveCorruptCargo.tscn",
		"tooltip":"HEVLIB_SAVEOPT_FIX_CORRUPTED_CARGO_TOOLTIP",
		"connect_method":"_pressed",
		"enable_on_save":true,
		"send_additional_info":true
	},
	{
		"display_name":"HEVLIB_SAVEOPT_CLEAR_SOLD_SHIPS",
		"popup_path":"res://HevLib/scenes/better_title_screen/FixSoldShipIssues.tscn",
		"tooltip":"HEVLIB_SAVEOPT_CLEAR_SOLD_SHIPS_TOOLTIP",
		"connect_method":"_pressed",
		"enable_on_save":true,
		"send_additional_info":true
	},
#	{
#		"display_name":"TEST",
#		"popup_path":"res://HevLib/scenes/better_title_screen/example/example.tscn",
#		"connect_method":"_pressed",
#		"enable_on_save":true,
#		"send_additional_info":true
#	},
]
