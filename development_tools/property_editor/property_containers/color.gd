tool
extends HBoxContainer

export (bool) var emit_update_signal = false

signal changed()

var value:Color = Color.black

func get_property_value():
	_select_color()
	return [value,"Color( %s , %s , %s , %s )" % [str(float(value.r)),str(float(value.g)),str(float(value.b)),str(float(value.a))]]

func set_property_value(property):
	if property is Color:
		var cr = $PanelContainer/ColorRect
		var cp = $AcceptDialog/PanelContainer/ColorPicker
		cr.color = Color(property.r,property.g,property.b,property.a)
		cp.color = Color(property.r,property.g,property.b,property.a)
		

func _ready():
	if not $PanelContainer/Button.is_connected("pressed",self,"_show_picker"):
		$PanelContainer/Button.connect("pressed",self,"_show_picker")
	if not $AcceptDialog.is_connected("confirmed",self,"_select_color"):
		$AcceptDialog.connect("confirmed",self,"_select_color")

func _show_picker():
	$AcceptDialog/PanelContainer/ColorPicker.color = value
	$AcceptDialog.popup_centered()

func _select_color():
	value = $AcceptDialog/PanelContainer/ColorPicker.color
	$PanelContainer/ColorRect.color = value
	_on_changed()

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")
