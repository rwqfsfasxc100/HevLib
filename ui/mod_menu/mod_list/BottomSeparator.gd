extends HBoxContainer

func _ready():
	modify()

func _visibility_changed():
	modify()
	
func modify():
	rect_min_size.y = 200
	var pos = get_parent().get_child_count()
	get_parent().call_deferred("move_child",self,pos)
