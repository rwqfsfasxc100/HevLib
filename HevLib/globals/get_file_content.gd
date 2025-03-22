extends Node

static func get_file_content(file):
	Debug.l("HevLib: function 'get_file_content' instanced data from %s" % file)
	var n = File.new()
	n.open(file, File.READ)
	var s = n.get_as_text()
	n.close()
	Debug.l("HevLib: get_file_content returning as %s" % s)
	return s
	
