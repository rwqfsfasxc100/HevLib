extends HBoxContainer


var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

export (String,"string","int") var store_method = "int"

var options = []

func _ready():
	var value = ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	store_method = CONFIG_DATA.get("store_method","int")
	$button/Label.text = CONFIG_DATA.get("name","OPTION_MISSING_NAME")
	for opt in CONFIG_DATA.get("options",[]):
		$OptionButton.add_item(opt,options.size())
		options.append(opt)
	
	$OptionButton.selected = find_int(value)
	$button/Label/LABELBUTTON.hint_tooltip = CONFIG_DATA.get("description","")
	add_to_group("hevlib_settings_tab",true)





func recheck_availability():
	var val = ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	
	$OptionButton.selected = find_int(val)
	var def = find_int(CONFIG_DATA.get("default",false))
	
	if $OptionButton.selected != def:
		$button/reset.visible = true
		$button/Label/LABELBUTTON.focus_neighbour_right = $button/Label/LABELBUTTON.get_path_to($button/reset)
	else:
		$button/reset.visible = false
		$button/Label/LABELBUTTON.focus_neighbour_right = $button/Label/LABELBUTTON.get_path_to($OptionButton)
	var requirements = PoolStringArray(CONFIG_DATA.get("requires_bools",[]))
	if requirements.size() >= 1:
		var show = true
		var valid_options = 0
		var true_valids = 0
		var flip = CONFIG_DATA.get("invert_bool_requirement",false)
		for option in requirements:
			
			var split = option.split("/")
			if split.size() == 3:
				var value = ConfigDriver.__get_value(split[0],split[1],split[2])
				if typeof(value) == TYPE_BOOL:
					valid_options += 1
					if value == true:
						true_valids += 1
		if valid_options >= 1:
			if flip:
				if true_valids >= 1:
					$button/reset.modulate = Color(0.6,0.6,0.6,1)
					$button/reset.disabled = true
					$OptionButton.modulate = Color(0.6,0.6,0.6,1)
					$OptionButton.disabled = true
				else:
					$button/reset.modulate = Color(1,1,1,1)
					$button/reset.disabled = false
					$OptionButton.modulate = Color(1,1,1,1)
					$OptionButton.disabled = false
			else:
				if true_valids >= 1:
					$button/reset.modulate = Color(1,1,1,1)
					$button/reset.disabled = false
					$OptionButton.modulate = Color(1,1,1,1)
					$OptionButton.disabled = false
				else:
					$button/reset.modulate = Color(0.6,0.6,0.6,1)
					$button/reset.disabled = true
					$OptionButton.modulate = Color(0.6,0.6,0.6,1)
					$OptionButton.disabled = true
	else:
		$button/reset.modulate = Color(1,1,1,1)
		$button/reset.disabled = false
		$OptionButton.modulate = Color(1,1,1,1)
		$OptionButton.disabled = false

func _reset_pressed():
	match store_method:
		"int":
			$OptionButton.selected = CONFIG_DATA.get("default",false)
		"string":
			var index = find_int(CONFIG_DATA.get("default",false))
			$OptionButton.selected = index
	ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,CONFIG_DATA.get("default",false))
	$OptionButton.grab_focus()
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _draw():
	
	refocus()

func refocus():
	$button/Label/LABELBUTTON.rect_size = $button/Label.rect_size
	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	
	ConfigDriver.__set_button_focus(self,get_node("OptionButton"))
	

func _visibility_changed():
	if get_position_in_parent() == 0:
		$button/Label/LABELBUTTON.grab_focus()
	refocus()


func _on_OptionButton_item_selected(index):
	
	match store_method:
		"int":
			ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,index)
		"string":
			var o = options[index]
			ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,o)
	
	
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func find_int(value):
	var i = 0
	match store_method:
		"string":
			if value in options:
				i = options.find(value)
			else:
				i = 0
		"int":
			if value >= options.size():
				i = 0
			else:
				i = value
	return i
