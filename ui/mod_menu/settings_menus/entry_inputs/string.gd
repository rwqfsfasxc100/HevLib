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
	$Label.text = CONFIG_DATA.get("name","STRING_MISSING_NAME")
	$LineEdit.text = value
	volatile = CONFIG_DATA.get("require_restart",false)
	$LineEdit.max_length = CONFIG_DATA.get("max_length",0)
	$LineEdit.secret = CONFIG_DATA.get("secret",false)
	$LineEdit.clear_button_enabled = CONFIG_DATA.get("clear_button",false)
	$LineEdit.placeholder_text = CONFIG_DATA.get("placeholder","HEVLIB_CONFIG_LINEEDIT_PLACEHOLDER")
	var desc = str(CONFIG_DATA.get("description",""))
	if volatile:
		if desc != "":
			desc = TranslationServer.translate(desc) + "\n\n" + TranslationServer.translate("HEVLIB_SETTING_REQUIRES_RESTART")
		else:
			desc = "HEVLIB_SETTING_REQUIRES_RESTART"
	$Label/LABELBUTTON.hint_tooltip = desc
	add_to_group("hevlib_settings_tab",true)


func recheck_availability():
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


func _reset_pressed():
	var defaultVal = CONFIG_DATA.get("default","")
	$LineEdit.text = defaultVal
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != defaultVal:
			triggerVolatile()
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,defaultVal)
	$LineEdit.grab_focus()
	$reset.visible = false
func _draw():
	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
	pointers.ConfigDriver.set_button_focus(self,get_node("LineEdit"))
	

func _visibility_changed():
	refocus()
	if get_position_in_parent() == 0:
		$Label/LABELBUTTON.grab_focus()
var caret_pos = 0

func _on_LineEdit_text_entered(new_text):
	caret_pos = $LineEdit.caret_position
	$LineEdit.text = new_text
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != new_text:
			triggerVolatile()
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,new_text)
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _process(delta):
	caret_pos = $LineEdit.text.length()
	$LineEdit.caret_position = caret_pos

func _timeout():
	$LineEdit.grab_focus()

var updateCacheDir = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
func triggerVolatile():
	var file = File.new()
	file.open(updateCacheDir,File.WRITE)
	file.store_string("1")
	file.close()
