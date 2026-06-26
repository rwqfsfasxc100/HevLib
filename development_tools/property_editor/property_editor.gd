extends VBoxContainer

# This tool is to provide an editor-like property editor available from in-game UI
# It's relatively limited, but should work for the most part
# Properties can be set or fetched with the set_property_value(property) and get_property_value() methods respectively.


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

var init_variable = null
var byte_init = false

var selected_property_type = "null"
var property_box = null

var ManifestConsts

func get_property_value():
	if property_box and property_box.has_method("get_property_value"):
		return property_box.get_property_value()

func set_property_value(property):
	_change_property_to(ManifestConsts.supported_property_types.find(match_property_to_typestring(property)))
	if property_box:
		property_box.set_property_value(property)

func clear():
	_change_property_to(ManifestConsts.supported_property_types.find("null"))

func initialize(how):
	init_variable = how

onready var edit_button = $box_alignment/EDIT
onready var type_select_popup = $TypeSelect
onready var type_selector = $TypeSelect/PanelContainer/OptionButton
onready var property_container = $box_alignment/property

func _ready():
	ManifestConsts = load("res://HevLib/development_tools/parts/ManifestConsts.gd")
	edit_button.visible = can_edit_type
	edit_button.connect("pressed",self,"_open_property_selector")
	type_select_popup.connect("confirmed",self,"_change_property_to")
	var lowType = []
	for i in ManifestConsts.supported_property_types:
		lowType.append(i.to_lower())
	property_type = ManifestConsts.supported_property_types[lowType.find(property_type.to_lower())]
	_change_property_to(ManifestConsts.supported_property_types.find(property_type))
	if init_variable != null:
		set_property_value(init_variable)
	$box_alignment/RESET.connect("pressed",self,"reset")

func _open_property_selector():
	type_selector.clear()
	for i in ManifestConsts.supported_property_types:
		type_selector.add_item(i)
	
	
	type_select_popup.popup_centered()

func _change_property_to(idx : int = -1):
	if idx < 0:
		idx = type_selector.selected
	if idx < 0:
		idx = 0
	var property = ManifestConsts.supported_property_types[idx]
	if property in ManifestConsts.property_nodes:
		var node = ManifestConsts.property_nodes[property].instance()
		property_box = node
		selected_property_type = property
		if property == "int":
			node.bytes = byte_init
		for i in $box_alignment/property.get_children():
			i.queue_free()
		
#		if hash(defaults_for_type[property_type]) != hash(ManifestConsts.defaults_for_property_type[property_type]):
		node.set_property_value(defaults_for_type[property_type])
		$box_alignment/property.add_child(node)

func match_property_to_typestring(property) -> String:
	var to = typeof(property)
	if to in ManifestConsts.property_assignment:
		return ManifestConsts.property_assignment[to] 
	return "null"

func reset():
	set_property_value(defaults_for_type[property_type])

func _draw():
	if property_box:
		property_box.update()
