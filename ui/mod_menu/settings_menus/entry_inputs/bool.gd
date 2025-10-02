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
	$Label.text = CONFIG_DATA.get("name","BOOL_MISSING_NAME")
	$CheckButton.pressed = value

func _toggled(button_pressed):
	ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,button_pressed)
	var tex = StreamTexture.new()
	if button_pressed:
		tex.load_path = "res://HevLib/ui/themes/icons/on_25.stex"
	else:
		tex.load_path = "res://HevLib/ui/themes/icons/off_25.stex"
	
	$CheckButton.icon = tex

func _process(_delta):
	$CheckButton.pressed = ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if $CheckButton.pressed != CONFIG_DATA.get("default",false):
		$reset.visible = true
	else:
		$reset.visible = false


func _reset_pressed():
	$CheckButton.pressed = CONFIG_DATA.get("default",false)
	ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,CONFIG_DATA.get("default",false))
	$CheckButton.grab_focus()

func _draw():
	
	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
	
	
	var parent = get_parent()
	var children = parent.get_children()
	var pos = get_position_in_parent()
	var icon_button = get_node("Label/LABELBUTTON")
	var reset_button = get_node("reset")
	var check_button = get_node("CheckButton")
	if pos == 0:
		icon_button.focus_neighbour_top = "."
		reset_button.focus_neighbour_top = "."
		check_button.focus_neighbour_top = "."

		icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
		reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
		check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))
	elif pos == children.size() - 1:
		icon_button.focus_neighbour_bottom = "."
		reset_button.focus_neighbour_bottom = "."
		check_button.focus_neighbour_bottom = "."

		icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
		reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
		check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))
	else:
		icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
		reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
		check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))

		icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
		reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
		check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))


func _visibility_changed():
	refocus()
