extends "res://hud/trtl/ProcessedCargoManifest.gd"

var processed_cargo_limiter_obj

func _ready():
	var p = ModLoader._savedObjects[0]
	processed_cargo_limiter_obj = load("res://HevLib/scenes/minerals/ShipInterrupt.gd").new(p)
	processed_cargo_limiter_obj.ship = ship
	ship = processed_cargo_limiter_obj

