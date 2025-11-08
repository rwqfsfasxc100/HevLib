extends "res://comms/ConversationPlayer.gd"

export (String) var spawnEvent = ""

const Events = preload("res://HevLib/pointers/Events.gd")

func execute():
	.execute()
	if spawnEvent and spawnEvent != "":
		Events.__spawn_event(spawnEvent,get_tree().get_root().get_node_or_null("Game/TheRing"))
