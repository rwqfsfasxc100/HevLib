extends Node

var developer_hint = {
	
}

const positional = preload("res://HevLib/scripts/ring_data/positional.gd")

static func __get_pixel_at(pos: Vector2) -> Color:
	return positional.getPixelAt(pos)

static func __get_vein_pixel_at(pos: Vector2) -> Color:
	return positional.getVeinPixelAt(pos)

static func __get_vein_at(pos: Vector2) -> String:
	return positional.getVeinAt(pos)

static func __get_chaos_at(pos):
	return __get_pixel_at(pos).r

static func __get_raw_density_at(pos):
	return __get_pixel_at(pos).b
