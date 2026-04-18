extends "res://asteroids/mineral.gd"

export var color = Color(1,1,1)
export var ferrous = false

func _ready():
	var o : Sprite = load("res://HevLib/scenes/minerals/icons/MineralOverlay.tscn").instance()
	var stream1 = StreamTexture.new()
	stream1.load_path = "res://HevLib/scenes/minerals/icons/minerals-c-overlay.stex"
	o.texture = stream1
	var stream2 = StreamTexture.new()
	stream2.load_path = "res://HevLib/scenes/minerals/icons/minerals-n-overlay.stex"
	o.normal_map = stream2
#	var stream3 = StreamTexture.new()
#	stream3.load_path = "res://HevLib/scenes/minerals/icons/minerals-m-overlay.stex"
#	o.material.set_shader_param("map",stream3)
	o.region_rect = sprite.region_rect
	o.region_enabled = true
	o.name = "Overlay"
	add_child(o)
	sprite.modulate = color
	name = mineral
	if ferrous:
		set_collision_layer_bit(5,true)
	
