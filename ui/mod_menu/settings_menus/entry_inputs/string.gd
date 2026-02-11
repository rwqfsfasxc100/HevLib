extends HBoxContainer

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _ready():
	var value = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	$Label.text = CONFIG_DATA.get("name","STRING_MISSING_NAME")
	$LineEdit.text = value
	$LineEdit.max_length = CONFIG_DATA.get("max_length",0)
	$LineEdit.secret = CONFIG_DATA.get("secret",false)
	$LineEdit.clear_button_enabled = CONFIG_DATA.get("clear_button",false)
	$LineEdit.placeholder_text = CONFIG_DATA.get("placeholder","HEVLIB_CONFIG_LINEEDIT_PLACEHOLDER")
	$Label/LABELBUTTON.hint_tooltip = CONFIG_DATA.get("description","")
	add_to_group("hevlib_settings_tab",true)


func recheck_availability():
#	if not $LineEdit.has_focus():
		
		$LineEdit.text = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if $LineEdit.text != CONFIG_DATA.get("default",""):
			$reset.visible = true
			$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($reset)
		else:
			$reset.visible = false
			$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($LineEdit)
		var requirements = PoolStringArray(CONFIG_DATA.get("requires_bools",[]))
		if requirements.size() >= 1:
			var show = true
			var valid_options = 0
			var true_valids = 0
			var flip = CONFIG_DATA.get("invert_bool_requirement",false)
			for option in requirements:
				
				var split = option.split("/")
				if split.size() == 3:
					var value = pointers.ConfigDriver.__get_value(split[0],split[1],split[2])
					if typeof(value) == TYPE_BOOL:
						valid_options += 1
						if value == true:
							true_valids += 1
			if valid_options >= 1:
				if flip:
					if true_valids >= 1:
						$reset.modulate = Color(0.6,0.6,0.6,1)
						$reset.disabled = true
						$LineEdit.modulate = Color(0.6,0.6,0.6,1)
						$LineEdit.editable = false
					else:
						$reset.modulate = Color(1,1,1,1)
						$reset.disabled = false
						$LineEdit.modulate = Color(1,1,1,1)
						$LineEdit.editable = true
				else:
					if true_valids >= 1:
						$reset.modulate = Color(1,1,1,1)
						$reset.disabled = false
						$LineEdit.modulate = Color(1,1,1,1)
						$LineEdit.editable = true
					else:
						$reset.modulate = Color(0.6,0.6,0.6,1)
						$reset.disabled = true
						$LineEdit.modulate = Color(0.6,0.6,0.6,1)
						$LineEdit.editable = false
		else:
			$reset.modulate = Color(1,1,1,1)
			$reset.disabled = false
			$LineEdit.modulate = Color(1,1,1,1)
			$LineEdit.editable = true
#	$LineEdit.caret_position = caret_pos


func _reset_pressed():
	$LineEdit.text = CONFIG_DATA.get("default","")
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,CONFIG_DATA.get("default",""))
	$LineEdit.grab_focus()
	$reset.visible = false
#	$LineEdit.caret_position = caret_pos
func _draw():

	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
#	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	pointers.ConfigDriver.__set_button_focus(self,get_node("LineEdit"))
#	$LineEdit.caret_position = caret_pos
	

func _visibility_changed():
	refocus()
	if get_position_in_parent() == 0:
		$Label/LABELBUTTON.grab_focus()
#	$LineEdit.caret_position = caret_pos
var caret_pos = 0

func _on_LineEdit_text_entered(new_text):
	caret_pos = $LineEdit.caret_position
	$LineEdit.text = new_text
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,new_text)
	get_tree().call_group("hevlib_settings_tab","recheck_availability")
#	$Timer.start()

func _process(delta):
	caret_pos = $LineEdit.text.length()
	$LineEdit.caret_position = caret_pos

func _timeout():
	$LineEdit.grab_focus()
