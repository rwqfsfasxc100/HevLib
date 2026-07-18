# This tool is to provide an editor-like property editor available from in-game UI
# It's relatively limited, but should work for the most part
# Properties can be set or fetched with the set_property_value(property) and get_property_value() methods respectively.

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

tool
extends VBoxContainer

# If enabled, allows the user to change the property type
export (bool) var can_edit_type = true

# Sets the initial propert type for the box
export (String,"null","bool","int","float","string","Vector2","Rect2","Vector3","Transform2D","Color","Dictionary","Array","PoolByteArray","PoolIntArray","PoolRealArray","PoolStringArray","PoolVector2Array","PoolVector3Array","PoolColorArray") var property_type = "null"

# Defines defaults for each variable type
export (Dictionary) var defaults_for_type = {
	"null":null,
	"bool":false,
	"int":0,
	"float":0.0,
	"string":"",
	"Vector2":Vector2.ZERO,
	"Rect2":Rect2(),
	"Vector3":Vector3.ZERO,
	"Transform2D":Transform2D(),
	"Color":Color.black,
	"Dictionary":{},
	"Array":[],
	"PoolByteArray":PoolByteArray(),
	"PoolIntArray":PoolIntArray(),
	"PoolRealArray":PoolRealArray(),
	"PoolStringArray":PoolStringArray(),
	"PoolVector2Array":PoolVector2Array(),
	"PoolVector3Array":PoolVector3Array(),
	"PoolColorArray":PoolColorArray(),
}

signal changed()

var init_variable = null
var byte_init = false

var selected_property_type = "null"
var property_box = null

func get_property_value():
	if property_box and property_box.has_method("get_property_value"):
		return property_box.get_property_value()

func set_property_value(property):
	_change_property_to(supported_property_types.find(match_property_to_typestring(property)))
	if property_box:
		property_box.set_property_value(property)

func clear():
	_change_property_to(supported_property_types.find("null"))


func initialize(how):
	init_variable = how
	set_property_value(init_variable)

var has_changed = false

func _enter_tree():
	if not has_changed:
		$box_alignment/EDIT.visible = can_edit_type
		$box_alignment/EDIT.connect("pressed",self,"_open_property_selector")
		$TypeSelect.connect("confirmed",self,"_change_property_to")
		var lowType = []
		for i in supported_property_types:
			lowType.append(i.to_lower())
		property_type = supported_property_types[lowType.find(property_type.to_lower())]
		_change_property_to(supported_property_types.find(property_type))
		if init_variable != null:
			set_property_value(init_variable)
		$box_alignment/RESET.connect("pressed",self,"reset")
		has_changed = true

func _open_property_selector():
	$TypeSelect/PanelContainer/OptionButton.clear()
	for i in supported_property_types:
		$TypeSelect/PanelContainer/OptionButton.add_item(i)
	
	
	$TypeSelect.popup_centered()

func _change_property_to(idx : int = -1):
	if idx < 0:
		idx = $TypeSelect/PanelContainer/OptionButton.selected
	if idx < 0:
		idx = 0
	var property = supported_property_types[idx]
	if property in property_nodes:
		var node = property_nodes[property].instance()
		node.connect("changed",self,"_on_changed")
		property_box = node
		selected_property_type = property
		if property == "int":
			node.bytes = byte_init
		for i in $box_alignment/property.get_children():
			i.queue_free()
		node.set_property_value(defaults_for_type[property_type])
		$box_alignment/property.add_child(node)
	_on_changed()

func _on_changed():
	pass
#	emit_signal("changed")

func match_property_to_typestring(property) -> String:
	var to = typeof(property)
	if to in property_assignment:
		return property_assignment[to] 
	return "null"

func reset():
	set_property_value(defaults_for_type[property_type])

func _draw():
	if property_box:
		property_box.update()

const supported_property_types = [
	"null",
	"bool",
	"int",
	"float",
	"string",
	"Vector2",
	"Rect2",
	"Vector3",
	"Transform2D",
	"Color",
	"Dictionary",
	"Array",
	"PoolByteArray",
	"PoolIntArray",
	"PoolRealArray",
	"PoolStringArray",
	"PoolVector2Array",
	"PoolVector3Array",
	"PoolColorArray",
]

const property_assignment = {
	TYPE_NIL:"null",
	TYPE_BOOL:"bool",
	TYPE_INT:"int",
	TYPE_REAL:"float",
	TYPE_STRING:"string",
	TYPE_VECTOR2:"Vector2",
	TYPE_RECT2:"Rect2",
	TYPE_VECTOR3:"Vector3",
	TYPE_TRANSFORM2D:"Transform2D",
	TYPE_COLOR:"Color",
	TYPE_DICTIONARY:"Dictionary",
	TYPE_ARRAY:"Array",
	TYPE_RAW_ARRAY:"PoolByteArray",
	TYPE_INT_ARRAY:"PoolIntArray",
	TYPE_REAL_ARRAY:"PoolRealArray",
	TYPE_STRING_ARRAY:"PoolStringArray",
	TYPE_VECTOR2_ARRAY:"PoolVector2Array",
	TYPE_VECTOR3_ARRAY:"PoolVector3Array",
	TYPE_COLOR_ARRAY:"PoolColorArray",
}

var property_nodes = {
	"null":load("res://HevLib/development_tools/property_editor/property_containers/null.tscn"),
	"bool":load("res://HevLib/development_tools/property_editor/property_containers/bool.tscn"),
	"int":load("res://HevLib/development_tools/property_editor/property_containers/int.tscn"),
	"float":load("res://HevLib/development_tools/property_editor/property_containers/float.tscn"),
	"string":load("res://HevLib/development_tools/property_editor/property_containers/string.tscn"),
	"Vector2":load("res://HevLib/development_tools/property_editor/property_containers/vec2.tscn"),
	"Vector3":load("res://HevLib/development_tools/property_editor/property_containers/vec3.tscn"),
	"Rect2":load("res://HevLib/development_tools/property_editor/property_containers/rect2.tscn"),
	"Transform2D":load("res://HevLib/development_tools/property_editor/property_containers/transform2d.tscn"),
	"Color":load("res://HevLib/development_tools/property_editor/property_containers/color.tscn"),
	"Dictionary":load("res://HevLib/development_tools/property_editor/property_containers/dict.tscn"),
	"Array":load("res://HevLib/development_tools/property_editor/property_containers/array.tscn"),
	"PoolByteArray":load("res://HevLib/development_tools/property_editor/property_containers/poolbytearray.tscn"),
	"PoolIntArray":load("res://HevLib/development_tools/property_editor/property_containers/poolintarray.tscn"),
	"PoolRealArray":load("res://HevLib/development_tools/property_editor/property_containers/poolrealarray.tscn"),
	"PoolStringArray":load("res://HevLib/development_tools/property_editor/property_containers/poolstringarray.tscn"),
	"PoolVector2Array":load("res://HevLib/development_tools/property_editor/property_containers/poolvector2array.tscn"),
	"PoolVector3Array":load("res://HevLib/development_tools/property_editor/property_containers/poolvector3array.tscn"),
	"PoolColorArray":load("res://HevLib/development_tools/property_editor/property_containers/poolcolorarray.tscn"),
}
