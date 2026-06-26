tool
extends HBoxContainer

export (String) var property_display_name = ""
export (String,MULTILINE) var property_description = ""

export (String) var section_name = ""
export (String) var entry_name = ""

export (int) var default = 0

var data : int = 0

var mod_box = get_node_or_null(NodePath(".."))

onready var LABEL = $TOOLTIP/Label
onready var SPINBOX = $Panel/SpinBox

func _ready():
	if not default:
		default = 0
	LABEL.text = property_display_name
	LABEL.get_parent().hint_tooltip = property_display_name + "\n\n" + property_description
	connect("visibility_changed",self,"_on_visibility_changed")
	yield(get_tree(),"physics_frame")
	yield(get_tree(),"physics_frame")
	SPINBOX.value = default

func _on_visibility_changed():
	if Engine.editor_hint:
		return
	if not mod_box:
		mod_box = get_node_or_null(NodePath(".."))
	SPINBOX.value = data
	yield(get_tree(),"idle_frame")
	SPINBOX.rect_size.x = $Panel.rect_size.x - 10
	LABEL.rect_size = LABEL.get_parent().rect_size
	LABEL.rect_position = Vector2(0,0)

func export_as():
	return [section_name,{entry_name:$Panel/SpinBox.value}]

func import_as(STATE):
	if section_name in STATE:
		var sv = STATE[section_name]
		if entry_name in sv:
			var entry = sv[entry_name]
			if entry is int or entry is float:
				SPINBOX.value = int(entry)
	update()
