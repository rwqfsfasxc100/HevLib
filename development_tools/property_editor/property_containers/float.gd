tool
extends MarginContainer

export (bool) var emit_update_signal = false

signal changed()

var value:float = 0.0

func get_property_value():
	_LE_text_changed($LineEdit.text)
	return [value,str(value)]

func set_property_value(property):
	if property is int or property is float:
		$LineEdit.text = str(float(property))

func _ready():
	if not $LineEdit.is_connected("text_entered",self,"_LE_text_changed"):
		$LineEdit.connect("text_entered",self,"_LE_text_changed")
	if not $LineEdit.is_connected("focus_exited",self,"_lost_focus"):
		$LineEdit.connect("focus_exited",self,"_lost_focus")

func _LE_text_changed(text:String):
	var ft = float(text)
	$LineEdit.text = str(ft)
	value = ft
	_on_changed()

func _lost_focus():
	var txt = $LineEdit.text
	_LE_text_changed(txt)

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")
