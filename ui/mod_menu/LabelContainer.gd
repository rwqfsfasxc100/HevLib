extends HBoxContainer

export var label_path = NodePath("")
onready var lb = get_node(label_path)

onready var button = get_parent()

func _visibility_changed():
	if lb:
		var rt = lb.rect_size
		button.rect_size = rt
	
