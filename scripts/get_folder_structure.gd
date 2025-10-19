extends Node

static func get_folder_structure(folder,store_file_content = false):
	var FolderAccess = load("res://HevLib/pointers/FolderAccess.gd")
	var file = File.new()
	var folder_structure = {}
	var files = FolderAccess.__fetch_folder_files(folder,true,false)
	for object in files:
		if object.ends_with("/"):
			var data = FolderAccess.__get_folder_structure(folder+object,store_file_content)
			folder_structure.merge({object:data})
		else:
			var fd = "FILE"
			if store_file_content:
				file.open(folder + object,File.READ)
				fd = file.get_as_text(true)
				file.close()
			folder_structure.merge({object:fd})
	return folder_structure
	
