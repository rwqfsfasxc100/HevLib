extends MarginContainer

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
	$SpinBox.connect("value_changed",self,"recheck")

func recheck(how):
	var sb = $SpinBox
	sb.allow_greater = not bytes
	sb.allow_lesser = not bytes
