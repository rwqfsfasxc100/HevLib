extends Node

var ship

var pointers

func _init(p):
	pointers = p
	pointers.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointers:
		cargo_limit = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","processed_mineral_max_display_limit")

var cargo_limit = 15

var page = 0


var counter = 0
func handle_list(ores,oresize) -> Array:
	if oresize > cargo_limit:
		var out = []
		counter += 1
		var offset = page * cargo_limit
		var thisSize = min(cargo_limit,oresize - offset)
		
		var pages = ceil(oresize / cargo_limit)
		for i in range(thisSize):
			out.append(ores[offset + i])
		
		
		
		if counter >= 50:
			counter = 0
			if page + 1 >= pages:
				page = 0
			else:
				page += 1
		return out
	else:
		counter = 0
		page = 0
		return ores









func getProcessedCargoTypes(how):
	var out = ship.getProcessedCargoTypes(how)
	var s = out.size()
	if s:
		return handle_list(out,s)
	return out


func getProcessedCargo(which,how):
	var out = ship.getProcessedCargo(which,how)
	
	return out


func getProcessedCargoCapacity(how):
	var out = ship.getProcessedCargoCapacity(how)
	
	return out

func soundAlert():
	ship.soundAlert()

