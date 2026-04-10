extends "res://hud/trtl/ProcessedCargoManifest.gd"

var obj

func _ready():
	var p = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
	obj = load("res://HevLib/scenes/minerals/ShipInterrupt.gd").new(p)
	obj.ship = ship
	ship = obj

