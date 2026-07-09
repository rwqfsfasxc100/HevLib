tool
extends HBoxContainer

export (bool) var emit_update_signal = false

signal changed()

var Xvalue:float = 0.0
var Yvalue:float = 0.0
var Zvalue:float = 0.0

func get_property_value():
	_X_text_changed($XBOX/X.text)
	_Y_text_changed($YBOX/X.text)
	_Z_text_changed($ZBOX/X.text)
	return [Vector3(Xvalue,Yvalue,Zvalue),"Vector3( %s , %s , %s )" % [str(Xvalue),str(Yvalue),str(Zvalue)]]

func set_property_value(property):
	if property is Vector3:
		var xb = $XBOX/X
		var yb = $YBOX/X
		var zb = $ZBOX/X
		xb.text = str(property.x)
		yb.text = str(property.y)
		zb.text = str(property.z)

func _ready():
	if not $XBOX/X.is_connected("text_entered",self,"_X_text_changed"):
		$XBOX/X.connect("text_entered",self,"_X_text_changed")
	if not $XBOX/X.is_connected("focus_exited",self,"_X_lost_focus"):
		$XBOX/X.connect("focus_exited",self,"_X_lost_focus")
	if not $YBOX/X.is_connected("text_entered",self,"_Y_text_changed"):
		$YBOX/X.connect("text_entered",self,"_Y_text_changed")
	if not $YBOX/X.is_connected("focus_exited",self,"_Y_lost_focus"):
		$YBOX/X.connect("focus_exited",self,"_Y_lost_focus")
	if not $ZBOX/X.is_connected("text_entered",self,"_Z_text_changed"):
		$ZBOX/X.connect("text_entered",self,"_Z_text_changed")
	if not $ZBOX/X.is_connected("focus_exited",self,"_Z_lost_focus"):
		$ZBOX/X.connect("focus_exited",self,"_Z_lost_focus")

func _X_text_changed(text:String):
	var ft = float(text)
	$XBOX/X.text = str(ft)
	Xvalue = ft
	_on_changed()

func _X_lost_focus():
	var txt = $XBOX/X.text
	_X_text_changed(txt)

func _Y_text_changed(text:String):
	var ft = float(text)
	$YBOX/X.text = str(ft)
	Yvalue = ft
	_on_changed()

func _Y_lost_focus():
	var txt = $YBOX/X.text
	_Y_text_changed(txt)

func _Z_text_changed(text:String):
	var ft = float(text)
	$ZBOX/X.text = str(ft)
	Zvalue = ft
	_on_changed()

func _Z_lost_focus():
	var txt = $ZBOX/X.text
	_Z_text_changed(txt)

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")
