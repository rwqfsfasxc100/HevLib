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
	
	
var logCache = ""
func l(msg:String, title:String = "HevLib Research Overhead"):
	var line = "[%s]: %s" % [title, msg]
	Debug.l(line)
	logCache += line + "\n"

var deviceinfostore:String = "user://cache/.Mod_Menu_2_Cache/EssentialsLogCache/"
var deviceinfocache:String = deviceinfostore + "DeviceInfoCache"

func storeLogCache():
	var file = File.new()
	file.open(deviceinfocache,File.READ)
	var ov = file.get_as_text(true)
	file.close()
	ov += logCache
	file.open(deviceinfocache,File.WRITE)
	file.store_string(ov)
	file.close()
	logCache = ""
