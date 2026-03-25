extends Node

export var slot = ""

export var system = ""

var ship
func _enter_tree():
	ship = getShip()
	ship.setConfig(slot,system)
	Tool.remove(self)

func getShip():
	var c = self
	while not c.has_method("getConfig") and c != null:
		c = c.get_parent()
	return c
