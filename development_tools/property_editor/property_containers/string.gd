tool
extends MarginContainer

export (bool) var emit_update_signal = false

signal changed()

func get_property_value():
	var value = $TextEdit.text
	return [value,str(value)]

func set_property_value(property):
	if property is String:
		$TextEdit.text = property

func _draw():
	rect_min_size.y = clamp($TextEdit.get_line_count() * $TextEdit.get_line_height(),$TextEdit.get_line_height(),$TextEdit.get_line_height() * 5) + 12

func _ready():
	if not $TextEdit.is_connected("text_changed",self,"update"):
		$TextEdit.connect("text_changed",self,"update")
	if not $TextEdit.is_connected("text_changed",self,"_on_changed"):
		$TextEdit.connect("text_changed",self,"_on_changed")

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")
