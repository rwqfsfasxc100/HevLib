extends HBoxContainer


var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""
var pointers = ModLoader._savedObjects[0]

export (String,"string","int") var store_method = "int"

var options = []

var volatile = false

func _ready():
	var value = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	volatile = CONFIG_DATA.get("require_restart",false)
	store_method = CONFIG_DATA.get("store_method","int")
	$Label.text = CONFIG_DATA.get("name","OPTION_MISSING_NAME")
	for opt in CONFIG_DATA.get("options",[]):
		$OptionButton.add_item(opt,options.size())
		options.append(opt)
	var desc = str(CONFIG_DATA.get("description",""))
	if volatile:
		if desc != "":
			desc = TranslationServer.translate(desc) + "\n\n" + TranslationServer.translate("HEVLIB_SETTING_REQUIRES_RESTART")
		else:
			desc = "HEVLIB_SETTING_REQUIRES_RESTART"
	$OptionButton.selected = find_int(value)
	$Label/LABELBUTTON.hint_tooltip = desc
	add_to_group("hevlib_settings_tab",true)





func recheck_availability():
	var val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	
	$OptionButton.selected = find_int(val)
	var def = find_int(CONFIG_DATA.get("default",find_int(0)))
	
	if $OptionButton.selected != def:
		$reset.visible = true
		$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($reset)
	else:
		$reset.visible = false
		$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($OptionButton)
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
					$OptionButton.modulate = Color(0.6,0.6,0.6,1)
					$OptionButton.disabled = true
				else:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					$OptionButton.modulate = Color(1,1,1,1)
					$OptionButton.disabled = false
			else:
				if true_valids >= 1:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					$OptionButton.modulate = Color(1,1,1,1)
					$OptionButton.disabled = false
				else:
					$reset.modulate = Color(0.6,0.6,0.6,1)
					$reset.disabled = true
					$OptionButton.modulate = Color(0.6,0.6,0.6,1)
					$OptionButton.disabled = true
	else:
		$reset.modulate = Color(1,1,1,1)
		$reset.disabled = false
		$OptionButton.modulate = Color(1,1,1,1)
		$OptionButton.disabled = false

func _reset_pressed():
	var defaultVal = CONFIG_DATA.get("default",find_int(0))
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != defaultVal:
			triggerVolatile()
	match store_method:
		"int":
			$OptionButton.selected = defaultVal
		"string":
			var index = find_int(defaultVal)
			$OptionButton.selected = index
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,defaultVal)
	$OptionButton.grab_focus()
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _draw():
	
	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
	pointers.ConfigDriver.set_button_focus(self,get_node("OptionButton"))
	

func _visibility_changed():
	if get_position_in_parent() == 0:
		$Label/LABELBUTTON.grab_focus()
	refocus()


func _on_OptionButton_item_selected(index):
	match store_method:
		"int":
			if volatile:
				var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
				if old_val != index:
					triggerVolatile()
			pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,index)
		"string":
			var o = options[index]
			if volatile:
				var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
				if old_val != o:
					triggerVolatile()
			pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,o)
	
	
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

var updateCacheDir = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
func triggerVolatile():
	var file = File.new()
	file.open(updateCacheDir,File.WRITE)
	file.store_string("1")
	file.close()
