extends Tabs

var section_info = {}

var section_values = {}

var mod = ""

func _draw():
	$MarginContainer.rect_size = rect_size
	$MarginContainer/ScrollContainer/VBoxContainer.rect_min_size = $MarginContainer.rect_size


func _ready():
	for entry in section_info:
		var entry_info = section_info[entry]
		var entry_values = section_values[entry]
		
		var type = entry_info["type"].to_lower()
		match type:
			"bool","boolean":
				var input = BOOL.instance()
				input.name = entry
				input.CONFIG_DATA = entry_info
				input.CONFIG_ENTRY = entry
				input.CONFIG_SECTION = name
				input.CONFIG_MOD = mod
				$MarginContainer/ScrollContainer/VBoxContainer.add_child(input)
			"float","int","integer","real":
				var input = INT_FLOAT.instance()
				input.name = entry
				input.CONFIG_DATA = entry_info
				input.CONFIG_ENTRY = entry
				input.CONFIG_SECTION = name
				input.CONFIG_MOD = mod
				match type:
					"int","integer":
						input.val_type = "int"
					"float","real":
						input.val_type = "float"
				$MarginContainer/ScrollContainer/VBoxContainer.add_child(input)
				pass
			
	
	
#	breakpoint



const BOOL = preload("res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.tscn")
const INT_FLOAT = preload("res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.tscn")
