extends HBoxContainer

func _ready():
	modify()

func _visibility_changed():
	modify()
	
func modify():
	var vertical = get_parent().get_child(0).rect_size.y*2
	self.rect_min_size.y = vertical
	var pos = get_parent().get_child_count()
	get_parent().call_deferred("move_child",self,pos)
