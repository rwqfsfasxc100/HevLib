extends Node

static func convert_var_from_string(string : String, folder : String = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/file_caches"):
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	if folder.ends_with("/"):
		pass
	else:
		folder = folder + "/"
	FolderAccess.__check_folder_exists(folder)
	var header = "extends Node\n\nconst VARIABLE = "
	var file = File.new()
	file.open(folder + "conversion.gd",File.WRITE)
	file.store_string(header + string)
	file.close()
	var script = load(folder + "conversion.gd")
	var variable = script.VARIABLE
	return variable
