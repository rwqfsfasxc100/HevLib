extends CheckButton

var event = ""

var eventNode
var ringNode

func _ready():
	for events in get_parent().get_parent().ring.get_children():
		if events.name == event:
			eventNode = events
	ringNode = eventNode.get_parent()

var NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd").new()

func _toggled(button_pressed):
	if button_pressed:
		var childs = self.get_child_count()
		if childs == 1:
			NodeAccess.__reparent(get_child(0),ringNode)

	else:
		var nt = ringNode.get_node(event)
		NodeAccess.__reparent(nt, self)
		
