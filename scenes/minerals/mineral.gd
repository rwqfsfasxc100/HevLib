extends "res://asteroids/mineral.gd"

const overlay = preload("res://HevLib/scenes/minerals/icons/MineralOverlay.tscn")

export var color = Color(1,1,1)

func _ready():
	var o = overlay.instance()
	o.region_rect = sprite.region_rect
	o.region_enabled = true
	o.name = "Overlay"
	add_child(o)
	sprite.modulate = color
	name = mineral
