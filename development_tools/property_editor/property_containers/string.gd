extends MarginContainer

func get_property_value():
	var value = $TextEdit.text
	return [value,str(value)]

func set_property_value(property):
	if property is String:
		$TextEdit.text = property

func _draw():
	rect_min_size.y = clamp($TextEdit.get_line_count() * $TextEdit.get_line_height(),$TextEdit.get_line_height(),$TextEdit.get_line_height() * 5)

func _ready():
	$TextEdit.connect("text_changed",self,"update")
