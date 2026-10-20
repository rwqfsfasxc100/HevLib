extends Node

var parent

func _unhandled_input(event:InputEvent):
	parent.get_inputevent(event)
