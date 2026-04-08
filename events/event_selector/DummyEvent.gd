extends Node

var ncount = 0
var format = "_%d"

var obj = RigidBody2D.new()
func _ready():
	name = format % ncount

func canBeAt(pos):
	ncount += 1
	name = format % ncount
	Tool.remove(obj)
	obj = RigidBody2D.new()
	obj.name = name
	Debug.l("EventDriver: Dummy event selected and returning blank object, presumably playlist is empty")
	return true

func makeAt(pos):
	return obj
