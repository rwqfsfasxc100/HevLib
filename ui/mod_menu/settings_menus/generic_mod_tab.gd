extends Tabs

export var mod = ""
export var mod_id = ""

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
const ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

const tab_base = preload("res://HevLib/ui/mod_menu/settings_menus/generic_section_tab.tscn")

onready var container = $MarginContainer/TabContainer

func _ready():
	name = mod
	var data = ConfigDriver.__get_config(mod)
	var mdata = ManifestV2.__get_mod_by_id(mod_id)["manifest"]["manifest_data"].get("configs",{})
	
	for section in mdata:
		var sec_data = mdata[section]
		var tab = tab_base.instance()
		tab.name = section
		tab.section_info = sec_data
		tab.section_values = data[section]
		tab.mod = mod
		container.add_child(tab)
	
#func _process(_delta):
func _draw():
	$MarginContainer.rect_size = rect_size
	
	name = mod
