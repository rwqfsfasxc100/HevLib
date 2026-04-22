extends "res://hud/trtl/ProcessedCargoManifest.gd"

var processed_cargo_limiter_obj

func _ready():
	var p = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
	processed_cargo_limiter_obj = load("res://HevLib/scenes/minerals/ShipInterrupt.gd").new(p)
	processed_cargo_limiter_obj.ship = ship
	ship = processed_cargo_limiter_obj

