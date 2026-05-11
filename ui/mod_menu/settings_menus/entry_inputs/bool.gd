extends HBoxContainer

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")

var volatile = false

func _ready():
	var value = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	volatile = CONFIG_DATA.get("require_restart",false)
	$Label.text = CONFIG_DATA.get("name","BOOL_MISSING_NAME")
	$CheckButton.pressed = value
	var desc = str(CONFIG_DATA.get("description",""))
	if volatile:
		if desc != "":
			desc = TranslationServer.translate(desc) + "\n\n" + TranslationServer.translate("HEVLIB_SETTING_REQUIRES_RESTART")
		else:
			desc = "HEVLIB_SETTING_REQUIRES_RESTART"
	$Label/LABELBUTTON.hint_tooltip = desc
	add_to_group("hevlib_settings_tab",true)

func _toggled(button_pressed):
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != button_pressed:
			triggerVolatile()
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,button_pressed)
	var tex = StreamTexture.new()
	if button_pressed:
		tex.load_path = "res://HevLib/ui/themes/icons/on_25.stex"
	else:
		tex.load_path = "res://HevLib/ui/themes/icons/off_25.stex"
	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	
	$CheckButton.icon = tex

func recheck_availability():
	$CheckButton.pressed = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if $CheckButton.pressed != CONFIG_DATA.get("default",false):
		$reset.visible = true
		$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($reset)
	else:
		$reset.visible = false
		$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($CheckButton)
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
					$CheckButton.modulate = Color(0.6,0.6,0.6,1)
					$CheckButton.disabled = true
				else:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					$CheckButton.modulate = Color(1,1,1,1)
					$CheckButton.disabled = false
			else:
				if true_valids >= 1:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					$CheckButton.modulate = Color(1,1,1,1)
					$CheckButton.disabled = false
				else:
					$reset.modulate = Color(0.6,0.6,0.6,1)
					$reset.disabled = true
					$CheckButton.modulate = Color(0.6,0.6,0.6,1)
					$CheckButton.disabled = true
	else:
		$reset.modulate = Color(1,1,1,1)
		$reset.disabled = false
		$CheckButton.modulate = Color(1,1,1,1)
		$CheckButton.disabled = false

func _reset_pressed():
	var defaultVal = CONFIG_DATA.get("default",false)
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != defaultVal:
			triggerVolatile()
	$CheckButton.pressed = defaultVal
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,defaultVal)
	$CheckButton.grab_focus()
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _draw():
	
	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
	pointers.ConfigDriver.__set_button_focus(self,get_node("CheckButton"))
	

func _visibility_changed():
	if get_position_in_parent() == 0:
		$Label/LABELBUTTON.grab_focus()
	refocus()

var updateCacheDir = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
func triggerVolatile():
	var file = File.new()
	file.open(updateCacheDir,File.WRITE)
	file.store_string("1")
	file.close()
