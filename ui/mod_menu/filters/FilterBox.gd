extends HBoxContainer

signal changed_tag(tag,change)

func _ready():
	connect("changed_tag",get_parent().get_parent().get_parent(),"update_filters")
	


func _toggled(button_pressed):
	emit_signal("changed_tag",self.name,button_pressed)
