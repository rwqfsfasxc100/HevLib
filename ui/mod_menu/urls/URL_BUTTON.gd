extends HBoxContainer

var url = ""
var text = ""
var icon_path = "res://HevLib/ui/themes/icons/alias.stex"

func _ready():
	$Button.text = text
	$Control/TextureRect.texture.load_path = icon_path
#	breakpoint

func _pressed():
	OS.shell_open(url)
