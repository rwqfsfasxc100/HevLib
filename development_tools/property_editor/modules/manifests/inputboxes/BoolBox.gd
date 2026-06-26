tool
extends HBoxContainer

export (String) var property_display_name = ""
export (String,MULTILINE) var property_description = ""

export (String) var section_name = ""
export (String) var entry_name = ""

export (bool) var default = false

var data : bool = false

var mod_box = get_node_or_null(NodePath(".."))

onready var LABEL = $TOOLTIP/Label
onready var SPINBOX = $Panel/CheckButton

func _ready():
	if not default:
		default = false
	LABEL.text = property_display_name
	LABEL.get_parent().hint_tooltip = property_display_name + "\n\n" + property_description
	connect("visibility_changed",self,"_on_visibility_changed")
	yield(get_tree(),"physics_frame")
	yield(get_tree(),"physics_frame")
	SPINBOX.pressed = default

func _on_visibility_changed():
	if Engine.editor_hint:
		return
	if not mod_box:
		mod_box = get_node_or_null(NodePath(".."))
	SPINBOX.pressed = data
	yield(get_tree(),"idle_frame")
	SPINBOX.rect_size.x = $Panel.rect_size.x - 10
	LABEL.rect_size = LABEL.get_parent().rect_size
	LABEL.rect_position = Vector2(0,0)

func export_as():
	return [section_name,{entry_name:SPINBOX.pressed}]

func import_as(STATE):
	if section_name in STATE:
		var sv = STATE[section_name]
		if entry_name in sv:
			var entry = sv[entry_name]
			if entry is bool:
				SPINBOX.pressed = entry
	update()
