extends HBoxContainer

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _ready():
	var value = ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	$Label.text = CONFIG_DATA.get("name","STRING_MISSING_NAME")
	$LineEdit.text = value
	$LineEdit.max_length = CONFIG_DATA.get("max_length",0)
	$LineEdit.secret = CONFIG_DATA.get("secret",false)
	$LineEdit.clear_button_enabled = CONFIG_DATA.get("clear_button",false)
	$LineEdit.placeholder_text = CONFIG_DATA.get("placeholder","HEVLIB_CONFIG_LINEEDIT_PLACEHOLDER")
	$Label/LABELBUTTON.hint_tooltip = CONFIG_DATA.get("description","")
