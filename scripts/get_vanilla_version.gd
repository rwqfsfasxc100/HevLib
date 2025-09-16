extends Node

static func get_vanilla_version() -> Array:
	var version = [1,0,0]
	var pls = File.new()
	pls.open("res://VersionLabel.tscn",File.READ)
	var ptxt = pls.get_as_text(true)
	pls.close()
	for line in ptxt.split("\n"):
		if line.begins_with("text = "):
			var data = line.split(" = ")[1].split(".")
			version[0] = int(data[0])
			version[1] = int(data[1])
			version[2] = int(data[2])
	return version
