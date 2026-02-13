extends Node

static func get_script_variables_without_load(script_path,DataFormat = null) -> Dictionary:
		var filepath = "user://cache/.HevLib_Cache/"
		var pathway = DataFormat.trim_scripts(script_path)
		if pathway[2].size() == 0:
			return {}
		var file = File.new()
		var dir = Directory.new()
		var n = filepath + str(Time.get_ticks_usec()) + ".gd"
		file.open(n,File.WRITE)
		file.store_string(pathway[0])
		file.close()
		var dict = {}
		var l = load(n).new()
		for i in pathway[1]:
			dict[i] = l.get(i)
		dir.remove(n)
		return dict
