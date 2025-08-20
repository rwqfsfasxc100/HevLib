extends Node

var mod_name : String = "HevLib"

var show_dialogue_box : bool = true
var dialogue_box_title : String = "HEVLIB_SELF_CHECK_ERROR_HEADER"

var crash_if_not_found : bool = true

var modmain_res_path : String = "res://HevLib/ModMain.gd"

var custom_message_string : String = "HEVLIB_SELF_CHECK_ERROR_MESSAGE"

var open_download_page_on_OK : bool = false
var download_URL : String = ""





# Variable used to decide the query. Can be fetched if set to not close the game
var mod_exists : bool










# Main function body

func _ready():
	Debug.l("HevLib Instance Validator: starting check for path validity")
	mod_exists = false
	var dir = Directory.new()
	var does = dir.file_exists(modmain_res_path)
	if does:
		mod_exists = true
	else:
		mod_exists = false
	if mod_exists:
		Debug.l("HevLib Instance Validator: %s exists at the proper path" % mod_name)
	else:
		if show_dialogue_box:
			var box = AcceptDialog.new()
			box.connect("confirmed", self, "_confirmed_pressed")
			box.window_title = dialogue_box_title
			box.popup_exclusive = true
			box.rect_min_size = Vector2(300,150)
			
			box.dialog_text = custom_message_string
			box.visible = true
		else:
			_confirmed_pressed()
		pass

func _confirmed_pressed():
	if open_download_page_on_OK:
		Debug.l("HevLib Instance Validator: attempting to open downloads link @ [%s]" % download_URL)
		OS.shell_open(download_URL)
	if not mod_exists and crash_if_not_found:
		Debug.l("HevLib Instance Validator: %s not found at the appropriate load path, exiting game" % mod_name)
		Loader.go(exit)
	
onready var exit = Loader.prepare("res://Exit.tscn")
