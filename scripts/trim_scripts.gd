extends Node

const function_prefixes = [
		"func ",
		"static func ",
		"remote func ",
		"master func ",
		"puppet func ",
		"remotesync func ",
		"mastersync func ",
		"puppetsync func ",
		"sync func "
	]
static func trim_scripts(file_path : String):
	var file = File.new()
	file.open(file_path,File.READ)
	var data = file.get_as_text(true)
	file.close()
	
	
	var streaming = false
	var this_stream : String = ""
	var concat : String = ""
	var const_names = []
	var var_names = []
	
	var lines = data.split("\n")
	for line in lines:
		var result : String = ""
		var is_part_of_string = false
		var prev_char_escape = false
		while line != "":
			var part:String = line.substr(0,1)
			if part == "\\":
				prev_char_escape = !prev_char_escape
			else:
				prev_char_escape = false
			if part == "\"" and not prev_char_escape:
				is_part_of_string = !is_part_of_string
			if part == "#" and (not is_part_of_string and not prev_char_escape):
				break
			
			
			pass
			line.erase(0,1)
			result += part
		line = result
		var has_prefix = false
		for prefix in function_prefixes:
			if line.begins_with(prefix):
				has_prefix = true
		if has_prefix:
			if streaming:
				concat = concat + this_stream.strip_edges() + "\n"
				this_stream = ""
				streaming = false
		elif line.begins_with("const "):
			if streaming:
				concat = concat + this_stream.strip_edges() + "\n"
				this_stream = ""
				streaming = false
			var cname = line.split("=",false)[0].strip_edges().split("const ",true)[1].strip_edges().split(":",false)[0].strip_edges()
			const_names.append(cname)
			streaming = true
		elif line.begins_with("var "):
			if streaming:
				concat = concat + this_stream.strip_edges() + "\n"
				this_stream = ""
				streaming = false
			var vname = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
			var_names.append(vname)
			streaming = true
		elif line.begins_with("export") and " var " in line:
			if streaming:
				concat = concat + this_stream.strip_edges() + "\n"
				this_stream = ""
				streaming = false
			var vname = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
			var_names.append(vname)
			streaming = true
		elif line.begins_with("onready") and " var " in line:
			if streaming:
				concat = concat + this_stream.strip_edges() + "\n"
				this_stream = ""
				streaming = false
			var vname = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
			var_names.append(vname)
			streaming = true
		elif line.begins_with("extends "):
			if streaming:
				concat = concat + this_stream.strip_edges() + "\n"
				this_stream = ""
				streaming = false
			streaming = true
		if streaming:
			this_stream = this_stream + "\n" + line
	if streaming:
		concat = concat + this_stream.strip_edges() + "\n"
		this_stream = ""
		streaming = false
	return [concat,var_names,const_names]
