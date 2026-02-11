extends "res://comms/ConversationPlayer.gd"

export (String) var spawnEvent = ""

#const Events = preload("res://HevLib/pointers/Events.gd")
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
func execute():
	.execute()
	if spawnEvent and spawnEvent != "":
		pointers.Events.__spawn_event(spawnEvent,get_tree().get_root().get_node_or_null("Game/TheRing"))
