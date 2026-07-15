extends "res://asteroids/mineral.gd"

export var color = Color(1,1,1)
export var ferrous = false

func _ready():
	var o : Sprite = load("res://HevLib/scenes/minerals/icons/MineralOverlay.tscn").instance()
	o.region_rect = sprite.region_rect
	o.scale = sprite.scale
	o.position = sprite.position
	add_child(o)
	sprite.modulate = color
	name = mineral
	if ferrous:
		set_collision_layer_bit(5,true)
	
