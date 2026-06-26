tool
extends HBoxContainer

export (String) var property_display_name = ""
export (String,MULTILINE) var property_description = ""

export (String) var section_name = ""
export (String) var entry_name = ""

export (int) var default = 0

var mod_box = get_node_or_null(NodePath(".."))

onready var LABEL = $TOOLTIP/Label
onready var SPINBOX = $Panel/SpinBox
onready var TOGGLE = $CheckButton

func _ready():
	if not default:
		default = 0
	LABEL.text = property_display_name
	TOGGLE.connect("toggled",self,"_on_toggle")
	LABEL.get_parent().hint_tooltip = property_display_name + "\n\n" + property_description
	connect("visibility_changed",self,"_on_visibility_changed")

var is_enabled = false

func _on_toggle(how:bool):
	is_enabled = how


func _on_visibility_changed():
	if Engine.editor_hint:
		return
	if not mod_box:
		mod_box = get_node_or_null(NodePath(".."))
	TOGGLE.pressed = is_enabled
	SPINBOX.value = default
	yield(get_tree(),"idle_frame")
	SPINBOX.rect_size.x = $Panel.rect_size.x - 10
	LABEL.rect_size = LABEL.get_parent().rect_size
	LABEL.rect_position = Vector2(0,0)


func export_as():
	breakpoint

func import_as(STATE):
	breakpoint
	update()
