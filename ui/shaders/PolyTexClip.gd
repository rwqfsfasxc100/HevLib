tool
extends Polygon2D

onready var parent = get_node_or_null("..")

func _enter_tree():
	yield(get_tree(),"idle_frame")
	if parent and parent is Sprite:
		var poly:PoolVector2Array = PoolVector2Array()
		var rect:Rect2 = parent.get_rect()
		var pos:Vector2 = rect.position
		var size:Vector2 = rect.size
		poly.append(pos)
		poly.append(Vector2(pos.x,size.y))
		poly.append(size)
		poly.append(Vector2(size.x,pos.y))
		polygon = poly
	

func set_clip_polygon(poly: PoolVector2Array) -> void:
	var hframes:int = parent.hframes
	var vframes:int = parent.vframes
	var frame_count:int = hframes * vframes
	var frame_size: Vector2 = parent.texture.get_size() / Vector2(hframes, vframes)

	var width:int = max(1, poly.size())

	var img:Image = Image.new()
	img.create(width, frame_count, false, Image.FORMAT_RGBAF)
	img.lock()
	for f in frame_count:
		for i in poly.size():
			var uv: Vector2 = poly[i] / frame_size
			var count_val:float = float(poly.size()) if i == 0 else 0.0
			img.set_pixel(i, f, Color(uv.x, uv.y, count_val, 1.0))
	img.unlock()

	var tex:ImageTexture = ImageTexture.new()
	tex.create_from_image(img, 0)

	parent.material.set_shader_param("poly_tex", tex)
	parent.material.set_shader_param("tex_width", width)
	parent.material.set_shader_param("hframes", hframes)
	parent.material.set_shader_param("vframes", vframes)

func _draw():
	if parent and parent is Sprite:
		if parent.centered:
			position = parent.get_rect().position
		set_clip_polygon(polygon)
