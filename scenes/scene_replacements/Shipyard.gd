extends "res://ships/Shipyard.gd"

func _ready():
	var timer = Timer.new()
	timer.name = "removal_timer"
	timer.one_shot = true
	timer.wait_time = 10
	timer.connect("timeout",self,"resetter_timeout")
	add_child(timer)
	timer.start()

func resetter_timeout():
	for ship in ships:
		var path = ships[ship].resource_path
		var replacement = ResourceLoader.load(path,"PackedScene",true)
		ships[ship] = null
		ships[ship] = replacement
	Tool.remove(get_node("removal_timer"))
#	breakpoint
