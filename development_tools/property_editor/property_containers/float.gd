extends MarginContainer

var value:float = 0.0

func get_property_value():
	_LE_text_changed($LineEdit.text)
	return [value,str(value)]

func set_property_value(property):
	if property is int or property is float:
		$LineEdit.text = str(float(property))

func _ready():
	$LineEdit.connect("text_entered",self,"_LE_text_changed")
	$LineEdit.connect("focus_exited",self,"_lost_focus")

func _LE_text_changed(text:String):
	var ft = float(text)
	$LineEdit.text = str(ft)
	value = ft

func _lost_focus():
	var txt = $LineEdit.text
	_LE_text_changed(txt)
