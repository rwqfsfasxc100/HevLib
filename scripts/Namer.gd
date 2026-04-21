extends "res://namer/Namer.gd"

var namer_store = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/namer.json"
var file = File.new()

func _ready():
	file.open(namer_store,File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	
	# Hardcoded
	data["crew"].append(["usa","Celine","Nguyen",0])
	
	for item in data["ships"]:
		var iv = item[0]
		if iv == "en" or iv == "verbatim":
			names["ship"][iv].append([item[1],item[2],0.5])
	for item in data["crew"]:
		var iv = item[0]
		var gender = item[3]
		if iv == "usa" or iv == "verbatim":
			names["crew"][iv].append([item[1],item[2],gender])
			if gender > 0:
				names["male"][iv].append([item[1],item[2],gender])
			if gender < 1:
				names["female"][iv].append([item[1],item[2],gender])
