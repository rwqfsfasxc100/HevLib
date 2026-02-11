extends Node

static func webtranslate_reset_by_file_check(file_check):
	var did = false
	var folder_to_delete = ""
	var cache = "user://cache/.HevLib_Cache/WebTranslate/"
	var dir = Directory.new()
	var pointers = preload("res://HevLib/pointers.gd").new()
	var files = pointers.FolderAccess.__fetch_folder_files(cache, true, true)
	for file in files:
		if not file.ends_with("/"):
			continue
		var cFiles = pointers.FolderAccess.__fetch_folder_files(file, false, true)
		for f in cFiles:
			if not f.ends_with(".file_check_cache"):
				continue
			var fo = File.new()
			fo.open(f,File.READ)
			var txt = fo.get_as_text()
			fo.close()
			if txt == file_check:
				folder_to_delete = file
			else:
				continue
	if not folder_to_delete == "":
		did = pointers.FolderAccess.__recursive_delete(folder_to_delete)
	pointers.free()
	return did
