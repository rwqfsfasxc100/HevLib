extends Node

static func get_mod_main(file, split_into_array = false):
	Debug.l("HevLib: function 'get_mod_main' instanced on %s. Outputting to an array? [%s]" % [file, split_into_array])
	var Globals = preload("res://HevLib/Functions.gd").new()
	var hasManifest = false
	var manifestDir = ""
	var hasIcon = false
	var iconDir = ""
	var modData
	var modMainPath = ""
	var filesInZip = Globals.__get_zip_content(file)
	for m in filesInZip:
		var modPath = "res://" + m
		m = m.split(m.split("/")[0] + "/")[1].to_lower()
		if m.begins_with("mod") and m.ends_with(".manifest"):
			Debug.l("HevLib Loader Storage: Loading manifest file @%s" % modPath)
			hasManifest = true
			manifestDir = modPath
		if m.begins_with("icon") and m.ends_with(".stex"):
			Debug.l("HevLib Loader Storage: Loading manifest file @%s" % modPath)
			hasIcon = true
			iconDir = modPath
		if m.begins_with("modmain") and m.ends_with(".gd"):
			Debug.l("HevLib Loader Storage: Loading ModMain file @%s" % modPath)
			modMainPath = modPath
	modData = Globals.__load_file(modMainPath, file, hasManifest, manifestDir, hasIcon, iconDir)
	if split_into_array:
		modData = modData.split("\n")
	Debug.l("HevLib: get_mod_main returning as %s" % modData)
	if modMainPath != null:
		return modData
	else:
		return null
