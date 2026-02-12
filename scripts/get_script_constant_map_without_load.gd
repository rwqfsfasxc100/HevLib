extends Node

static func get_script_constant_map_without_load(script_path,trim_scripts) -> Dictionary:
	var filepath = "user://cache/.HevLib_Cache/"
	var pathway = trim_scripts.trim_scripts(script_path)
	if pathway[2].size() == 0:
		return {}
	var file = File.new()
	var dir = Directory.new()
	var n = filepath + str(Time.get_ticks_usec()) + ".gd"
	file.open(n,File.WRITE)
	file.store_string(pathway[0])
	file.close()
	var dict = {}
	var l = load(n).new().get_script().get_script_constant_map()
	for i in pathway[2]:
		var fd = l.get(i)
		dict.merge({i:fd})
	dir.remove(n)
	return dict
