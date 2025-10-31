extends Node

var process = false

var current = ""

func _ready():
	
	
	
	
	pass

func loading_enceladus():
	set_deferred("current","enceladus")

func unloading():
	current = ""
	

func loading_asteroidfield():
	set_deferred("current","asteroidfield")





func check_validity():
	if CurrentGame.state.ship.keys() == 0:
		process = false
	else:
		process = true
	
	
func l(msg:String, title:String = "HevLib Research Overhead"):
	Debug.l("[%s V%s]: %s" % [title, msg])
