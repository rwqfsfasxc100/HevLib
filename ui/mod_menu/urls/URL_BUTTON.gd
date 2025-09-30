extends HBoxContainer

var url = ""
var text = ""
var tooltip = ""
var icon_path = "res://HevLib/ui/themes/icons/alias.stex"

func _ready():
	$Button/Label.text = text
	var tex = StreamTexture.new()
	tex.load_path = icon_path
	$Control/TextureRect.texture = tex
	$Button.hint_tooltip = tooltip
#	breakpoint

func _pressed():
	OS.shell_open(url)



func _resized():
	$Button/Label.rect_size = $Button.rect_size
