extends "res://hud/components/AnalogAxisDisplay.gd"

export var display_direction = false

var raw = ""

var farPos = 32
var alignPos = 16
var nearPos = 0

func _enter_tree():
	key = abs(key)
	if display_direction:
		var axisDirection = sign(key)
		if raw.begins_with("-"):
			axisDirection = -1
		match int(key):
			0:
				var directionalSprite = TextureRect.new()
				directionalSprite.rect_size = Vector2(24,24)
				directionalSprite.rect_pivot_offset = Vector2(12,12)
				directionalSprite.expand = true
				var stex = StreamTexture.new()
				stex.load_path = "res://HevLib/ui/themes/icons/arrow-up.stex"
				directionalSprite.texture = stex
				if axisDirection > -1:
					directionalSprite.rect_position = Vector2(farPos,alignPos)
					directionalSprite.rect_rotation = 90
				else:
					directionalSprite.rect_position = Vector2(nearPos,alignPos)
					directionalSprite.rect_rotation = 270
				get_node_or_null("Sprite").add_child(directionalSprite)
			1:
				var directionalSprite = TextureRect.new()
				directionalSprite.rect_size = Vector2(24,24)
				directionalSprite.rect_pivot_offset = Vector2(12,12)
				directionalSprite.expand = true
				var stex = StreamTexture.new()
				stex.load_path = "res://HevLib/ui/themes/icons/arrow-up.stex"
				directionalSprite.texture = stex
				if axisDirection > -1:
					directionalSprite.rect_position = Vector2(alignPos,farPos)
					directionalSprite.rect_rotation = 180
				else:
					directionalSprite.rect_position = Vector2(alignPos,nearPos)
					directionalSprite.rect_rotation = 0
				get_node_or_null("Sprite").add_child(directionalSprite)
			2:
				var directionalSprite = TextureRect.new()
				directionalSprite.rect_size = Vector2(24,24)
				directionalSprite.rect_pivot_offset = Vector2(12,12)
				directionalSprite.expand = true
				var stex = StreamTexture.new()
				stex.load_path = "res://HevLib/ui/themes/icons/arrow-up.stex"
				directionalSprite.texture = stex
				if axisDirection > -1:
					directionalSprite.rect_position = Vector2(farPos,alignPos)
					directionalSprite.rect_rotation = 90
				else:
					directionalSprite.rect_position = Vector2(nearPos,alignPos)
					directionalSprite.rect_rotation = 270
				get_node_or_null("Sprite").add_child(directionalSprite)
			3:
				var directionalSprite = TextureRect.new()
				directionalSprite.rect_size = Vector2(24,24)
				directionalSprite.rect_pivot_offset = Vector2(12,12)
				directionalSprite.expand = true
				var stex = StreamTexture.new()
				stex.load_path = "res://HevLib/ui/themes/icons/arrow-up.stex"
				directionalSprite.texture = stex
				if axisDirection > -1:
					directionalSprite.rect_position = Vector2(alignPos,farPos)
					directionalSprite.rect_rotation = 180
				else:
					directionalSprite.rect_position = Vector2(alignPos,nearPos)
					directionalSprite.rect_rotation = 0
				get_node_or_null("Sprite").add_child(directionalSprite)
			6:
				pass
			7:
				pass
			_:
				breakpoint
		
