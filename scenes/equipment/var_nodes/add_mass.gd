extends Node2D

export  var systemName = "SYSTEM_HEVLIB_INTERNALS_NODE"
export  var slot = ""
export  var slotName = ""
export (int) var mass = 0

var power = 0.0

func getStatus():
	return 100.0
func getPower():
	return power

var power_downcycle = false

func _physics_process(delta):
	if power >= 0.5:
		power_downcycle = true
	elif power <=0.0:
		power_downcycle = false
	if power_downcycle:
		power = clamp(power - (delta * 0.1),0,0.5)
	else:
		power = clamp(power + (delta * 0.1),0,0.5)

func getShip():
	var c = self
	while not c.has_method("getConfig") and c != null:
		c = c.get_parent()
	return c
