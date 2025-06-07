extends Node

static func match_mod_path_to_zip(mod_main_path:String) -> String:
	var _modZipFiles = []
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	var modPathPrefix = gameInstallDirectory.plus_file("mods")

	var dir = Directory.new()
	if dir.open(modPathPrefix) != OK:
		Debug.l("HevLib ManifestV2: Can't open mod folder %s." % modPathPrefix)
		return ""
	if dir.list_dir_begin() != OK:
		Debug.l("HevLib ManifestV2: Can't read mod folder %s." % modPathPrefix)
		return ""

	while true:
		var fileName = dir.get_next()
		if fileName == "":
			break
		if dir.current_is_dir():
			continue
		var modFSPath = modPathPrefix.plus_file(fileName)
		var modGlobalPath = ProjectSettings.globalize_path(modFSPath)
		if not ProjectSettings.load_resource_pack(modGlobalPath, true):
			Debug.l("HevLib ManifestV2: %s failed to add." % fileName)
			continue
		_modZipFiles.append(modFSPath)
		Debug.l("HevLib ManifestV2: %s added." % fileName)
	dir.list_dir_end()
	
	var initScripts = []
	Debug.l("HevLib ManifestV2: checking zips")
	for modFSPath in _modZipFiles:
		var gdunzip = load("res://vendor/gdunzip.gd").new()
		gdunzip.load(modFSPath)
		for modEntryPath in gdunzip.files:
			var modEntryName = modEntryPath.get_file().to_lower()
			if modEntryName.begins_with("modmain") and modEntryName.ends_with(".gd"):
				var modGlobalPath = "res://" + modEntryPath
				var zipName = modFSPath.split("/")[modFSPath.split("/").size() - 1]
				initScripts.append([modGlobalPath,zipName])
	for item in initScripts:
		if item[0] == mod_main_path:
			Debug.l("HevLib ManifestV2: %s matches, returning as %s." % [item[0],item[1]])
			return item[1]
	Debug.l("HevLib ManifestV2: no matches found, is the mod installed or run via the Godot editor?.")
	return ""
