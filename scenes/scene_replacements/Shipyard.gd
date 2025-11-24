extends "res://ships/Shipyard.gd"

func _ready():
#	var timer = Timer.new()
#	timer.name = "removal_timer"
#	timer.one_shot = true
#	timer.wait_time = 0.2
#	timer.connect("timeout",self,"resetter_timeout")
#	add_child(timer)
#	timer.start()
	resetter_timeout()

func resetter_timeout():
	for ship in ships:
		var path = ships[ship].resource_path
		var replacement = ResourceLoader.load(path,"PackedScene",true)
		ships[ship] = null
		ships[ship] = replacement
#	Tool.remove(get_node("removal_timer"))
#	breakpoint


func createShipByConfig(cfg: Dictionary, new = true, age = 24 * 3600 * 365 * 100, sd = 0):
	var ship = .createShipByConfig(cfg, new, age, sd)
	var script = load("res://ships/ship-ctrl.gd")
	ship.set_script(script)
	return ship
