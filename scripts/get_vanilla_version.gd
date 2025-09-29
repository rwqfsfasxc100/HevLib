extends Node

static func get_vanilla_version(get_from_files: bool = false) -> Array:
	var version = [1,0,0]
	if get_from_files:
		var pls = File.new()
		var v = "res://VersionLabel.tscn"
		if pls.file_exists(v):
			Debug.l("get_vanilla_version: Version Label exists")
		else:
			v = "res://VersionLabel.tscn.converted.res"
			Debug.l("get_vanilla_version: Version Label does not exist")
			
			if pls.file_exists(v):
				Debug.l("get_vanilla_version: Version Label RES exists")
			else:
				v = "res://.autoconverted/VersionLabel.tscn.converted.res"
				Debug.l("get_vanilla_version: Version Label RES does not exist")
				
				if pls.file_exists(v):
					Debug.l("get_vanilla_version: Version Label RES AC exists")
				else:
					v = ""
					Debug.l("get_vanilla_version: Version Label RES AC does not exist")
		if v == "":
			Debug.l("get_vanilla_version: Returning default due to no available scene")
			return version
		pls.open(v,File.READ)
		if v.ends_with(".res"):
			var txt = []
			while not pls.eof_reached():
				var line = pls.get_line()
				if line:
					txt.append(line)
			for ln in txt:
				var split = ln.split(".")
				if split.size() == 3:
					var all_ints = true
					for item in split:
						var tp = typeof(item)
						if tp != TYPE_INT:
							all_ints = false
					if all_ints:
						version[0] = int(split[0])
						version[1] = int(split[1])
						version[2] = int(split[2])
		else:
			var ptxt = pls.get_as_text(true)
			for line in ptxt.split("\n"):
				if line.begins_with("text = "):
					var data = line.split(" = ")[1].split(".")
					version[0] = int(data[0])
					version[1] = int(data[1])
					version[2] = int(data[2])
		pls.close()
	else:
		var pls = CurrentGame.version
		var data = pls.split(".")
		version[0] = int(data[0])
		version[1] = int(data[1])
		version[2] = int(data[2])
	return version
