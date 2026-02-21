extends Node

var password = "FTWOMG"

func _pressed(a,b):
	var f = File.new()
	if f.file_exists(a):
		f.open_encrypted_with_pass(a, File.READ, password)
		var sg = f.get_line()
		var savedState = parse_json(sg)
		if "soldShips" in savedState:
			savedState.soldShips.clear()
		f.close()
		f.open_encrypted_with_pass(a, File.WRITE, password)
		f.store_string(to_json(savedState))
		f.close()
