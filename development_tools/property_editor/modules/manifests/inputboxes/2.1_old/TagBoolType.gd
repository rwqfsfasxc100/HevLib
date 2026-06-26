tool
extends HBoxContainer

export (String) var property_display_name = ""
export (String,MULTILINE) var property_description = ""

export (String) var section_name = ""
export (String) var entry_name = ""

export (bool) var default = false

var mod_box = get_node_or_null(NodePath(".."))

onready var LABEL = $TOOLTIP/Label
onready var SPINBOX = $Value
onready var TOGGLE = $Enabled

func _ready():
	if not default:
		default = false
	LABEL.text = property_display_name
	SPINBOX.connect("pressed",self,"_on_text_changed")
	TOGGLE.connect("toggled",self,"_on_toggle")
	LABEL.get_parent().hint_tooltip = property_display_name + "\n\n" + property_description
	connect("visibility_changed",self,"_on_visibility_changed")

var is_enabled = false

func _on_toggle(how:bool):
	is_enabled = how
	_on_text_changed(SPINBOX.pressed)

func _on_text_changed(how:bool):
	if Engine.editor_hint:
		return
	if is_enabled:
		if not section_name in mod_box.STATE:
			mod_box.STATE[section_name] = {}
		mod_box.STATE[section_name][entry_name] = how
	else:
		mod_box.STATE[section_name].erase(entry_name)

func _on_visibility_changed():
	if Engine.editor_hint:
		return
	if not mod_box:
		mod_box = get_node_or_null(NodePath(".."))
	TOGGLE.pressed = is_enabled
	SPINBOX.pressed = default
	yield(get_tree(),"idle_frame")
	LABEL.rect_size = LABEL.get_parent().rect_size
	LABEL.rect_position = Vector2(0,0)


func export_as():
	breakpoint

func import_as(STATE):
	breakpoint
	update()
