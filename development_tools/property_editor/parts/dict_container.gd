tool
extends HBoxContainer

func get_property_value():
	var key = $key.get_property_value()
	var value = $value.get_property_value()
	return [{key[0]:value[0]},"{%s:%s}" % [key[1],value[1]]]

func set_property_value(key,value):
	$key.initialize(key)
	$value.initialize(value)

var parent_container = null

func _ready():
	if not $DELETE.is_connected("pressed",self,"_on_delete"):
		$DELETE.connect("pressed",self,"_on_delete")
	if not $ConfirmationDialog.is_connected("confirmed",self,"_do_delete"):
		$ConfirmationDialog.connect("confirmed",self,"_do_delete")

func _on_delete():
	$ConfirmationDialog.popup_centered()

func _do_delete():
	queue_free()
	if parent_container:
		parent_container.recalculate()
