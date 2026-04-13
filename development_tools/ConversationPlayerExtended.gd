# This script should be used for modified comms nodes and adds extra functionality.
extends "res://comms/ConversationPlayer.gd"

# Used to spawn an event when the conversation is run
export (String) var spawnEvent = ""

# Used to check against a config for any succeeding option
# Config must be valid (i.e. not returns null when checked), 
# and all three entries must be filled out to be used
export (String) var config_ID = ""
export (String) var config_section = ""
export (String) var config_setting = ""
# Whether the configuration should prevent the config when true
export (bool) var invert_config_logic = false


export (String) var special_name = ""
export (int) var special_price = 0

onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
func execute():
	.execute()
	if spawnEvent and spawnEvent != "":
		pointers.Events.__spawn_event(spawnEvent,get_tree().get_root().get_node_or_null("Game/TheRing"))
	
	if special_name and "specialName" in origin:
		origin.specialName = special_name
	if special_price and "specialPrice" in origin:
		origin.specialPrice = special_price
	
	

func canBeUsed(by) -> bool:
	var how = .canBeUsed(by)
	if how and config_ID and config_section and config_setting:
		var cfg_opt = pointers.ConfigDriver.__get_value(config_ID,config_section,config_setting)
		if cfg_opt != null:
			if invert_config_logic:
				if cfg_opt:
					how = false
			else:
				if !cfg_opt:
					how = false
	return how 
