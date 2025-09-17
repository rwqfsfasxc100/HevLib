extends AnimationPlayer

export var button_path = NodePath("")
export var icon_path = NodePath("")

var rotation_offset = 0
export var rotation_degs = 0

onready var icon = get_node(icon_path)

func _ready():
	
	var icon_size = icon.rect_size
	var repos = Vector2(icon_size.x / 2, icon_size.y / 2)
	icon.rect_pivot_offset = repos
	rotation_offset = icon.rotation
	connect("focus_entered",self,"_focused")
	connect("focus_exited",self,"_unfocused")

func _process(delta):
	var rot = deg2rad(rotation_degs) + rotation_offset
	icon.rotation = rot

func _focused():
	play("Hover")
	

func _unfocused():
	play("Unhover")
