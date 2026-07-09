tool
extends MarginContainer

export (bool) var emit_update_signal = false

signal changed()

var bytes = false

func get_property_value():
	var value = $SpinBox.value
	if bytes:
		value = value % 256
	return [value,str(value)]

func set_property_value(property):
	if property is int or property is float:
		if bytes:
			property = property % 256
		$SpinBox.value = int(property)

func _ready():
	if not $SpinBox.is_connected("value_changed",self,"recheck"):
		$SpinBox.connect("value_changed",self,"recheck")

func recheck(how):
	var sb = $SpinBox
	sb.allow_greater = not bytes
	sb.allow_lesser = not bytes
	_on_changed()

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")
