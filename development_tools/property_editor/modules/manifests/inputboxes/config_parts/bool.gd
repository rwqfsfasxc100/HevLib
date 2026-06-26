extends VBoxContainer

onready var NAME = $Box/MarginContainer/LABELS/NAME
onready var TYPE = $Box/MarginContainer/LABELS/TYPE
onready var BUTTON = $Box/MarginContainer/TOOLTIP
onready var ICON = $Box/TextureRect
onready var EDIT = $Box/EDIT
onready var EDITDIAG = $Box/EditDiag
onready var EDITDIAGLINE = $Box/EditDiag/LineEdit
onready var DELETE = $Box/DELETE
onready var COLLAPSIBLE = $Collapsible

var config_type = "bool"
var config_name = ""
onready var parent = get_node_or_null(NodePath("../.."))
func _ready():
	BUTTON.connect("pressed",self,"_on_toggle")
	EDIT.connect("pressed",self,"_on_edit_pressed")
	DELETE.connect("pressed",self,"_on_delete")
	EDITDIAG.connect("confirmed",self,"_on_name_change")
	set_this_name(config_name)
	
	NAME.text = config_name
	TYPE.text = "(boolean)"
	

var toggled = false

func _on_toggle():
	toggled = !toggled
	update()

func _draw():
	if ICON:
		ICON.rect_rotation = 180 if toggled else 0
		COLLAPSIBLE.visible = toggled

func _on_edit_pressed():
	EDITDIAGLINE.text = config_name
	EDITDIAG.popup_centered()
	EDITDIAGLINE.grab_focus()
	EDITDIAGLINE.caret_position = EDITDIAGLINE.text.length()

func _on_name_change():
	set_this_name(EDITDIAGLINE.text)

func set_this_name(vn:String):
	var oldSectionName = config_name
	config_name = vn
	NAME.text = vn
	if oldSectionName != vn:
		parent.rename(oldSectionName,vn)

func _on_delete():
	if parent:
		parent.delete(config_name)
