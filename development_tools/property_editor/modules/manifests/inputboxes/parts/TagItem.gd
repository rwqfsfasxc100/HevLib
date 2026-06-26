extends VBoxContainer

var item_name : String = ""
var item_dict : Dictionary = {}
var item_type = "null"

onready var LABEL = $Box/TOOLTIP/TEXTLABEL
onready var BUTTON = $Box/TOOLTIP
onready var ICON = $Box/TextureRect
onready var EDIT = $Box/EDIT
onready var EDITDIAG = $Box/EditDiag
onready var EDITDIAGLINE = $Box/EditDiag/LineEdit
onready var DELETE = $Box/DELETE

onready var parent = get_node_or_null(NodePath("../.."))

func _enter_tree():
	var pe = get_node_or_null("List/property_editor")
	pe.property_type = item_type
	pe.can_edit_type = false

func _ready():
	connect("visibility_changed",self,"_on_visibility_changed")
	BUTTON.connect("pressed",self,"_on_toggle")
	EDIT.connect("pressed",self,"_on_edit_pressed")
	DELETE.connect("pressed",self,"_on_delete")
	EDITDIAG.connect("confirmed",self,"_on_name_change")
	set_this_name(item_dict,item_name)

var toggled = false

func _on_toggle():
	toggled = !toggled
	update()

func _draw():
	if ICON:
		ICON.rect_rotation = 180 if toggled else 0
		$List.visible = toggled
	$List/property_editor.update()

var allow_change = true

func set_this_name(txt:Dictionary,vn:String):
	item_dict = txt
	item_name = vn
	allow_change = false
	LABEL.text = vn
	allow_change = true

func _on_url_changed(text: String):
	if allow_change:
		item_dict["URL"] = text

func _on_icon_changed(text: String):
	if allow_change:
		item_dict["ICON"] = text

func _on_tooltip_changed(text: String):
	if allow_change:
		item_dict["TOOLTIP"] = text

func _on_visibility_changed():
	if Engine.editor_hint:
		return
	
	
	yield(get_tree(),"idle_frame")
	LABEL.rect_size = LABEL.get_parent().rect_size
	LABEL.rect_position = Vector2(0,0)
	$List/property_editor.update()

func _on_edit_pressed():
	EDITDIAGLINE.text = item_name
	EDITDIAG.popup_centered()

func _on_name_change():
	item_name = EDITDIAGLINE.text
	set_this_name(item_dict,item_name)

func _on_delete():
	if parent:
		parent.delete(get_position_in_parent())

func export_as():
	var val = $List/property_editor.get_property_value()
	var v1 = val[0]
	return {item_name:{"type":item_type.to_lower(),"value":v1}}

func import_as(STATE):
	$List/property_editor.set_property_value(STATE)
