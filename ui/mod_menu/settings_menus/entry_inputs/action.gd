extends HBoxContainer

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

var script_path = ""

func _ready():
	$Label.text = CONFIG_DATA.get("name","BOOL_MISSING_NAME")
	$Label/LABELBUTTON.hint_tooltip = CONFIG_DATA.get("description","")
	script_path = CONFIG_DATA.get("script_path","")
	$ActionNode.set_script(load(script_path))
	$Button.text = CONFIG_DATA.get("button_label","")
	$Button.connect("pressed",$ActionNode,CONFIG_DATA.get("method","_pressed"))
	add_to_group("hevlib_settings_tab",true)

func _pressed():
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func recheck_availability():
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
					$Button.modulate = Color(0.6,0.6,0.6,1)
					$Button.disabled = true
				else:
					$Button.modulate = Color(1,1,1,1)
					$Button.disabled = false
			else:
				if true_valids >= 1:
					$Button.modulate = Color(1,1,1,1)
					$Button.disabled = false
				else:
					$Button.modulate = Color(0.6,0.6,0.6,1)
					$Button.disabled = true
	else:
		$Button.modulate = Color(1,1,1,1)
		$Button.disabled = false

func _draw():
	
	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	
	ConfigDriver.__set_button_focus(self,get_node("Button"))
	

