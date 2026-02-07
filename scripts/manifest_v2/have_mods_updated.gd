extends Node

static func have_mods_updated(folder: String,last_seen_file: String,this_file:String,FolderAccess = null) -> Dictionary:
	var file = File.new()
	if not folder.ends_with("/"):
		folder = folder + "/"
	if last_seen_file.begins_with("/"):
		last_seen_file.lstrip("/")
	var MV2 = load("res://HevLib/pointers/ManifestV2.gd")
	var all_mods = MV2.__get_mod_data()["mods"]
	FolderAccess.__check_folder_exists(folder)
	if not file.file_exists(folder + last_seen_file):
		file.open(folder + last_seen_file,File.WRITE)
		file.store_string("{}")
		file.close()
	var mods = {}
	for mod in all_mods:
		var data = all_mods[mod]
		if data["manifest"]["has_manifest"] and data["manifest"]["manifest_version"] >= 2.0:
			var manifest = data["manifest"]["manifest_data"]
			var info = manifest["mod_information"]
			var version = manifest["version"]
			mods[info["id"]] = {"name":info["name"],"version":{"major":version["version_major"],"minor":version["version_minor"],"bugfix":version["version_bugfix"]},"path":data["node"].get_script().get_path(),"changelog":manifest["manifest_definitions"]["changelog_path"]}
	var last = {}
	if file.file_exists(folder + last_seen_file):
		file.open(folder + last_seen_file,File.READ)
		last = JSON.parse(file.get_as_text()).result
		file.close()
	var changes = {}
	for mod in mods:
		var has_changed = false
		var data = mods[mod]
		if mod in last:
			if data["version"]["major"] != last[mod]["version"]["major"]:
				has_changed = true
			if data["version"]["minor"] != last[mod]["version"]["minor"]:
				has_changed = true
			if data["version"]["bugfix"] != last[mod]["version"]["bugfix"]:
				has_changed = true
		else:
			has_changed = true
		if has_changed:
			changes.merge({mod:data})
	pass
	
	return changes
