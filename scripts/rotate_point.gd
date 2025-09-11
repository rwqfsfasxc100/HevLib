extends Node

static func rotate_point(point: Vector2, angle: float, degrees: bool = true):
	if degrees:
		angle = deg2rad(angle)
	angle = -angle
	var x = point[0]
	var y = point[1]
	var xca = x*cos(angle)
	var ysa = y*sin(angle)
	var yca = y*cos(angle)
	var xsa = x*sin(angle)
	var p2 = Vector2(0,yca+xsa)
	p2.x = xca-ysa
	return p2
