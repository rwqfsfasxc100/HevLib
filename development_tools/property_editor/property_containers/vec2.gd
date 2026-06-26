extends HBoxContainer

var Xvalue:float = 0.0
var Yvalue:float = 0.0

func get_property_value():
	_X_text_changed($XBOX/X.text)
	_Y_text_changed($YBOX/Y.text)
	return [Vector2(Xvalue,Yvalue),"Vector2( %s , %s )" % [str(Xvalue),str(Yvalue)]]

func set_property_value(property):
	if property is Vector2:
		var xb = $XBOX/X
		var yb = $YBOX/Y
		xb.text = str(property.x)
		yb.text = str(property.y)

func _ready():
	$XBOX/X.connect("text_entered",self,"_X_text_changed")
	$XBOX/X.connect("focus_exited",self,"_X_lost_focus")
	$YBOX/Y.connect("text_entered",self,"_Y_text_changed")
	$YBOX/Y.connect("focus_exited",self,"_Y_lost_focus")

func _X_text_changed(text:String):
	var ft = float(text)
	$XBOX/X.text = str(ft)
	Xvalue = ft

func _X_lost_focus():
	var txt = $XBOX/X.text
	_X_text_changed(txt)

func _Y_text_changed(text:String):
	var ft = float(text)
	$YBOX/Y.text = str(ft)
	Yvalue = ft

func _Y_lost_focus():
	var txt = $YBOX/Y.text
	_Y_text_changed(txt)
