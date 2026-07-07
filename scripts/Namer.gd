extends "res://namer/Namer.gd"

func _ready():
	var data = ModLoader._savedObjects[0].Equipment.namer_store
	
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
