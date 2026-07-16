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

export (String,"","byte","int","float","string","Vector2","Vector3","Color") var specific_type = ""

export (bool) var emit_update_signal = false

signal changed()

func get_property_value():
	var value = []
	var string = ""
	for i in $Collapsable/List.get_children():
		if i.has_method("get_property_value"):
			var ov = i.get_property_value()
			value.append(ov[0])
			if string:
				string += ", " + ov[1]
			else:
				string = ov[1]
	var stv = "[%s]" % string
	return [value,stv]

func set_property_value(property):
	if is_array_type(property):
		for i in $Collapsable/List.get_children():
			i._do_delete()
		for i in property:
			_add_entry(i)

func getToggleText():
	match specific_type:
		"byte":
			return "PoolByteArray (size %d)"
		"int":
			return "PoolIntArray (size %d)"
		"float":
			return "PoolRealArray (size %d)"
		"string":
			return "PoolStringArray (size %d)"
		"Vector2":
			return "PoolVector2Array (size %d)"
		"Vector3":
			return "PoolVector3Array (size %d)"
		"Color":
			return "PoolColorArray (size %d)"
		_:
			return "Array (size %d)"

func is_array_type(property) -> bool:
	if property is Array:
		return true
	if property is PoolByteArray:
		specific_type = "byte"
		return true
	if property is PoolColorArray:
		specific_type = "Color"
		return true
	if property is PoolIntArray:
		specific_type = "int"
		return true
	if property is PoolRealArray:
		specific_type = "float"
		return true
	if property is PoolStringArray:
		specific_type = "string"
		return true
	if property is PoolVector2Array:
		specific_type = "Vector2"
		return true
	if property is PoolVector3Array:
		specific_type = "Vector3"
		return true
	return false

func _ready():
	$Collapsable.visible = false
	if not $Toggle/Button.is_connected("toggled",self,"_toggle_collapsed"):
		$Toggle/Button.connect("toggled",self,"_toggle_collapsed")
	$Toggle/Button.text = getToggleText() % 0
	if not $Collapsable/NEW/H/Add.is_connected("pressed",self,"_add_entry"):
		$Collapsable/NEW/H/Add.connect("pressed",self,"_add_entry")
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
	

func _add_entry(property = null):
	var ac = load("res://HevLib/development_tools/property_editor/parts/array_container.tscn").instance()
	if not ac.is_connected("changed",self,"_on_changed"):
		ac.connect("changed",self,"_on_changed")
	ac.parent_container = self
	ac.initialize_type = specific_type
	if property != null:
		ac.set_property_value(property)
	$Collapsable/List.add_child(ac)
	_on_changed()

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
	objList = get_list()
	var size = objList.size()
	$Toggle/Button.text = getToggleText() % size
	if $Collapsable/List.is_visible_in_tree():
		for i in objList:
			i.visible = false
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
