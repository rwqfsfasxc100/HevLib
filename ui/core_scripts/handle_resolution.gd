extends Node


static func handle_resolution(vpRect: Vector2, rightSpacePercent: int, leftSpacePercent: int, topSpacePercent: int, bottomSpacePercent: int, square: bool, vertical_align: String, horizontal_align: String):
	
#	var vpRect = get_parent().rect_size
	var screenWidth = vpRect.x
	var screenHeight = vpRect.y
#	var screenWidth = Settings.maxScreenScale.x - 2
#	var screenHeight = Settings.maxScreenScale.y - 2
#	if OS.get_name() == "Windows":
#		screenHeight -= 1
	
	var offsetW = leftSpacePercent / 100.0
	var offsetWidth = screenWidth * offsetW * 0.5
	var offsetH = topSpacePercent / 100.0
	var offsetHeight = screenHeight * offsetH * 0.5
	var offsetW2 = rightSpacePercent / 100.0
	var offsetWidth2 = screenWidth * offsetW2 * 0.5
	var offsetH2 = bottomSpacePercent / 100.0
	var offsetHeight2 = screenHeight * offsetH2 * 0.5
	var sizeW = abs((200.0 - rightSpacePercent - leftSpacePercent) / 200.0)
	var sizeWidth = screenWidth * sizeW
	var sizeH = abs((200.0 - bottomSpacePercent - topSpacePercent) / 200.0)
	var sizeHeight = screenHeight * sizeH
	
	offsetWidth = round(offsetWidth)
	offsetHeight = round(offsetHeight)
	sizeWidth = round(sizeWidth)
	sizeHeight = round(sizeHeight)
	
	if square:
		match vertical_align:
			"bottom":
				pass
			"center":
				pass
			_:
				pass
		match horizontal_align:
			"right":
				pass
			"center":
				pass
			_:
				pass
		
		
		if sizeHeight > sizeWidth:
			sizeHeight = sizeWidth
		else:
			sizeWidth = sizeHeight
	
	
	var rect_size = Vector2(sizeWidth, sizeHeight)
	var rect_position = Vector2(offsetWidth, offsetHeight)
	
	return [rect_size, rect_position]
