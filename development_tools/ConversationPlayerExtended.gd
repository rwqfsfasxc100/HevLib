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

#const Events = preload("res://HevLib/pointers/Events.gd")
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
func execute():
	.execute()
	if spawnEvent and spawnEvent != "":
		pointers.Events.__spawn_event(spawnEvent,get_tree().get_root().get_node_or_null("Game/TheRing"))

func canBeUsed(by) -> bool:
	var how = .canBeUsed(by)
	if how and config_ID and config_section and config_setting:
		var cfg_opt = pointers.ConfigDriver.__get_value(config_ID,config_section,config_setting)
		if cfg_opt != null:
			if !cfg_opt:
				how = false
	return how 
