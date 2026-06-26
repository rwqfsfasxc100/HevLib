extends HBoxContainer

var Xvalue:float = 0.0
var Yvalue:float = 0.0
var Wvalue:float = 0.0
var Hvalue:float = 0.0

func get_property_value():
	_X_text_changed($XBOX/X.text)
	_Y_text_changed($YBOX/Y.text)
	_W_text_changed($WBOX/W.text)
	_H_text_changed($HBOX/H.text)
	return [Rect2(Xvalue,Yvalue,Wvalue,Hvalue),"Rect2( %s , %s , %s , %s )" % [str(Xvalue),str(Yvalue),str(Wvalue),str(Hvalue)]]

func set_property_value(property):
	if property is Rect2:
		var xb = $XBOX/X
		var yb = $YBOX/Y
		var wb = $WBOX/W
		var hb = $HBOX/H
		xb.text = str(property.position.x)
		yb.text = str(property.position.y)
		wb.text = str(property.size.x)
		hb.text = str(property.size.y)

func _ready():
	$XBOX/X.connect("text_entered",self,"_X_text_changed")
	$XBOX/X.connect("focus_exited",self,"_X_lost_focus")
	$YBOX/Y.connect("text_entered",self,"_Y_text_changed")
	$YBOX/Y.connect("focus_exited",self,"_Y_lost_focus")
	$WBOX/W.connect("text_entered",self,"_W_text_changed")
	$WBOX/W.connect("focus_exited",self,"_W_lost_focus")
	$HBOX/H.connect("text_entered",self,"_H_text_changed")
	$HBOX/H.connect("focus_exited",self,"_H_lost_focus")

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

func _W_text_changed(text:String):
	var ft = float(text)
	$WBOX/W.text = str(ft)
	Wvalue = ft

func _W_lost_focus():
	var txt = $WBOX/W.text
	_W_text_changed(txt)

func _H_text_changed(text:String):
	var ft = float(text)
	$HBOX/H.text = str(ft)
	Hvalue = ft

func _H_lost_focus():
	var txt = $HBOX/H.text
	_H_text_changed(txt)
