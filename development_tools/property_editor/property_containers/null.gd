tool
extends MarginContainer

export (bool) var emit_update_signal = false

signal changed()

func get_property_value():
	return [null,"null"]

func set_property_value(_how):
	pass

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")
