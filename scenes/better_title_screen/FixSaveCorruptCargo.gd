extends Node

var file = File.new()
var password = "FTWOMG"

func _pressed(p,n):
	if file.file_exists(p):
		var has_changed = false
		file.open_encrypted_with_pass(p, File.READ, password)
		var data = JSON.parse(file.get_as_text(true)).result
		file.close()
		if "ship" in data:
			if "config" in data["ship"]:
				var f = data["ship"]["config"]
				if "currentCargo" in f and "currentCargoComposition" in f:
					var cargo = f["currentCargo"]
					var comp = f["currentCargoComposition"]
					for i in range(cargo.size()):
						if cargo[i] == "":
							cargo.remove(i)
							comp.remove(i)
							has_changed = true
		if has_changed:
			file.open_encrypted_with_pass(p, File.WRITE, password)
			file.store_string(JSON.print(data))
			file.close()
#			breakpoint
