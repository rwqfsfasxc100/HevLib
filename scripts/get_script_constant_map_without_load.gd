extends Node

static func get_script_constant_map_without_load(script_path : String):
	var file = File.new()
	if file.open(script_path,File.READ):
		return []
	else:
		var data = file.get_as_text(true)
		file.close()
		var constants = {}
		var cname = ""
		var cval = ""
		for line in data.split("\n"):
			if line.to_lower().begins_with("const "):
				if cname != "":
					constants[str2var(cname)] = str2var(str(cval))
				cname = ""
				cval = ""
				line.erase(0,6)
				var l = line.split("=")
				var n = l[0]
				while n.begins_with(" "):
					n = n.lstrip(" ")
				while n.ends_with(" "):
					n = n.rstrip(" ")
				var val = l[1]
				if typeof(val) == TYPE_STRING:
					while val.begins_with(" "):
						val = val.lstrip(" ")
					while val.ends_with(" "):
						val = val.rstrip(" ")
					if val == "INF":
						val = INF
					elif val == "-INF":
						val = -INF
					elif val == "PI":
						val = PI
					elif val == "-PI":
						val = -PI
					elif val == "TAU":
						val = TAU
					elif val == "-TAU":
						val = -TAU
					elif val == "NAN":
						val = NAN
					elif val == "-NAN":
						val = -NAN
				cname = n
				cval = val
				
			else:
				var vp = line.strip_escapes().length()
				if vp:
					cval = cval + "\n" + line.split("#")[0]
				else:
					if cname != "":
						constants[str2var(cname)] = str2var(str(cval))
					cname = ""
					cval = ""
		return constants
