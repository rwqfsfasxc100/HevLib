tool
extends VBoxContainer

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

func get_property_value():
	var value = {}
	var string = ""
	for i in get_list():
		var val = i.get_property_value()
		value.merge(val[0])
		var sv :String= val[1]
		if sv.begins_with("{") and sv.ends_with("}"):
			sv = sv.substr(1)
			sv = sv.substr(0,sv.length() - 1)
		if string:
			string += ", " + sv
		else:
			string = sv
	var stv = "{%s}" % string
	return [value,stv]

func set_property_value(property):
	if property is Dictionary:
		for i in $Collapsable/List.get_children():
			i._do_delete()
		for i in property:
			var val = property[i]
			$Collapsable/NEW/VBoxContainer/Key/property_editor.set_property_value(i)
			$Collapsable/NEW/VBoxContainer/Value/property_editor.set_property_value(val)
			_add_entry()

var toggle_text = "Dictionary (size %d)"

const dict_container = preload("res://HevLib/development_tools/property_editor/parts/dict_container.tscn")

func _ready():
	$Collapsable.visible = false
	if not $Toggle/Button.is_connected("toggled",self,"_toggle_collapsed"):
		$Toggle/Button.connect("toggled",self,"_toggle_collapsed")
	$Toggle/Button.text = toggle_text % 0
	if not $Collapsable/NEW/VBoxContainer/H/Add.is_connected("pressed",self,"_add_entry"):
		$Collapsable/NEW/VBoxContainer/H/Add.connect("pressed",self,"_add_entry")
	if not $Collapsable/Info/VBoxContainer/SIZE.is_connected("value_changed",self,"_size_value_changed"):
		$Collapsable/Info/VBoxContainer/SIZE.connect("value_changed",self,"_size_value_changed")
	if not $Collapsable/Info/VBoxContainer/PAGE.is_connected("value_changed",self,"_page_value_changed"):
		$Collapsable/Info/VBoxContainer/PAGE.connect("value_changed",self,"_page_value_changed")
	recalculate()

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")

func _toggle_collapsed(how:bool):
	var stream = StreamTexture.new()
	if how:stream.load_path = "res://HevLib/development_tools/property_editor/icons/expanded.stex"
	else:stream.load_path = "res://HevLib/development_tools/property_editor/icons/collapsed.stex"
	$Toggle/Button.icon = stream
	$Collapsable.visible = how
	recalculate()

func _add_entry():
	var key = $Collapsable/NEW/VBoxContainer/Key/property_editor.get_property_value()[0]
	var items = []
	for i in get_list():
		items.append(i.get_node("key").get_property_value()[0])
	if key in items:
		return
	var val = $Collapsable/NEW/VBoxContainer/Value/property_editor.get_property_value()[0]
	var cv = dict_container.instance()
	cv.set_property_value(key,val)
	cv.parent_container = self
	$Collapsable/List.add_child(cv)
	$Collapsable/NEW/VBoxContainer/Key/property_editor.set_property_value(null)
	$Collapsable/NEW/VBoxContainer/Value/property_editor.set_property_value(null)

const page_size = 20
var current_page = 0

func get_list():
	var out = []
	for i in $Collapsable/List.get_children():
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			out.append(i)
	return out

var objList = []
func recalculate():
	if $Collapsable/List.is_visible_in_tree():
		objList = get_list()
		for i in objList:
			i.visible = false
		var size = objList.size()
		$Toggle/Button.text = toggle_text % size
		$Collapsable/Info/VBoxContainer/SIZE.value = size
		
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		if size > page_size:
			for iv in range(clamp(size - offset,0,page_size)):
				objList[iv + offset].visible = true
			$Collapsable/Info/VBoxContainer/PAGE.visible = true
		else:
			for iv in objList:
				iv.visible = true
			$Collapsable/Info/VBoxContainer/PAGE.visible = false
			current_page = 0
		$Collapsable/Info/VBoxContainer/PAGE.value = current_page
	else:
		current_page = 0
	_on_changed()

func _size_value_changed(how:float):
	how = int(how)
	var sz = objList.size()
	if how != sz:
		if how < sz and sz > 0:
			objList[sz - 1]._on_delete()
		elif how > sz:
			$Collapsable/NEW/VBoxContainer/Key/property_editor.set_property_value(null)
			$Collapsable/NEW/VBoxContainer/Value/property_editor.set_property_value(null)
			_add_entry()
	recalculate()

func _page_value_changed(how:float):
	how = int(how)
	if how != current_page:
		var size = objList.size()
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		if how < current_page and current_page > 0:
			current_page -= 1
		elif how > current_page:
			if current_page < max_pages:
				current_page += 1
	recalculate()

func _draw():
	recalculate()
