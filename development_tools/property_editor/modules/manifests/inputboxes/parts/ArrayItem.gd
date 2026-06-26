extends HBoxContainer

var item_name : String = ""

onready var label = $TEXTLABEL
onready var button = $DELETE
onready var up = $MOVE_UP
onready var down = $MOVE_DOWN

onready var parent = get_node_or_null(NodePath("../.."))

func _ready():
	button.connect("pressed",self,"_on_delete")
	up.connect("pressed",self,"_on_up")
	down.connect("pressed",self,"_on_down")
	set_this_name(item_name)

func set_this_name(txt):
	item_name = txt
	label.text = txt

func _on_delete():
	if parent:
		parent.delete(get_position_in_parent())

func _on_up():
	if parent:
		parent.move(get_position_in_parent(),-1)

func _on_down():
	if parent:
		parent.move(get_position_in_parent(),1)


