tool
extends MarginContainer

export (bool) var emit_update_signal = false

signal changed()

func get_property_value():
	var value = $CheckButton.pressed
	return [value,"true" if value else "false"]

func set_property_value(property):
	var cb = $CheckButton
	if property:
		cb.pressed = true
	else:
		cb.pressed = false

func _ready():
	if not $CheckButton.is_connected("pressed",self,"_on_changed"):
		$CheckButton.connect("pressed",self,"_on_changed")

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")
