extends Node

static func get_mod_versions(store,folder,last_seen_file,this_seen_file) -> Dictionary:
	var mods = {}
	var MV2 = load("res://HevLib/pointers/ManifestV2.gd")
	var all_mods = MV2.__get_mod_data()["mods"]
	for mod in all_mods:
		var data = all_mods[mod]
		if data["manifest"]["has_manifest"] and data["manifest"]["manifest_version"] >= 2.0:
			var manifest = data["manifest"]["manifest_data"]
			var info = manifest["mod_information"]
			var version = manifest["version"]
			mods[info["id"]] = {"name":info["name"],"version":{"major":version["version_major"],"minor":version["version_minor"],"bugfix":version["version_bugfix"]}}
	if store:
		if not folder.ends_with("/"):
			folder = folder + "/"
		if last_seen_file.begins_with("/"):
			last_seen_file.lstrip("/")
		var file = File.new()
		var FolderAccess = load("res://HevLib/pointers/FolderAccess.gd")
		FolderAccess.__check_folder_exists(folder)
		if file.file_exists(folder + this_seen_file):
			file.open(folder + this_seen_file,File.READ)
			var lastData = JSON.parse(file.get_as_text()).result
			file.close()
			file.open(folder + last_seen_file,File.WRITE)
			file.store_string(JSON.print(lastData))
			file.close()
		file.open(folder + this_seen_file,File.WRITE)
		file.store_string(JSON.print(mods))
		file.close()
	return mods
