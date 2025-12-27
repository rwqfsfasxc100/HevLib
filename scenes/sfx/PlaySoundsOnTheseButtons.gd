extends "res://menu/sfx/PlaySoundsOnTheseButtons.gd"

func recurse(into):
	if is_instance_valid(into) and into != null:
		.recurse(into)
