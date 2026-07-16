tool
extends HBoxContainer

# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

export (bool) var emit_update_signal = false

signal changed()

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
	if not $XBOX/X.is_connected("text_entered",self,"_X_text_changed"):
		$XBOX/X.connect("text_entered",self,"_X_text_changed")
	if not $XBOX/X.is_connected("focus_exited",self,"_X_lost_focus"):
		$XBOX/X.connect("focus_exited",self,"_X_lost_focus")
	if not $YBOX/Y.is_connected("text_entered",self,"_Y_text_changed"):
		$YBOX/Y.connect("text_entered",self,"_Y_text_changed")
	if not $YBOX/Y.is_connected("focus_exited",self,"_Y_lost_focus"):
		$YBOX/Y.connect("focus_exited",self,"_Y_lost_focus")
	if not $WBOX/W.is_connected("text_entered",self,"_W_text_changed"):
		$WBOX/W.connect("text_entered",self,"_W_text_changed")
	if not $WBOX/W.is_connected("focus_exited",self,"_W_lost_focus"):
		$WBOX/W.connect("focus_exited",self,"_W_lost_focus")
	if not $HBOX/H.is_connected("text_entered",self,"_H_text_changed"):
		$HBOX/H.connect("text_entered",self,"_H_text_changed")
	if not $HBOX/H.is_connected("focus_exited",self,"_H_lost_focus"):
		$HBOX/H.connect("focus_exited",self,"_H_lost_focus")

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
	$YBOX/Y.text = str(ft)
	Yvalue = ft
	_on_changed()

func _Y_lost_focus():
	var txt = $YBOX/Y.text
	_Y_text_changed(txt)

func _W_text_changed(text:String):
	var ft = float(text)
	$WBOX/W.text = str(ft)
	Wvalue = ft
	_on_changed()

func _W_lost_focus():
	var txt = $WBOX/W.text
	_W_text_changed(txt)

func _H_text_changed(text:String):
	var ft = float(text)
	$HBOX/H.text = str(ft)
	Hvalue = ft
	_on_changed()

func _H_lost_focus():
	var txt = $HBOX/H.text
	_H_text_changed(txt)

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")
