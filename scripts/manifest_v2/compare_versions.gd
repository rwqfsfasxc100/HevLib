extends Node

static func compare_versions(checked_mod_data:Dictionary) -> bool:
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var installed_mods = ManifestV2.__get_mod_data(true)
	var check_name = checked_mod_data[checked_mod_data.keys()[0]].get("name","")
	var installed_dict = {}
	for installed_mod in installed_mods["mods"]:
		var installed_mName = installed_mods["mods"][installed_mod].get("name","")
		if installed_mName == check_name:
			installed_dict = installed_mods["mods"][installed_mod].duplicate()
	if installed_dict == {}:
		return false
	var checked_manifest_version = checked_mod_data[checked_mod_data.keys()[0]]["manifest"]["manifest_version"]
	var installed_manifest_version = installed_dict["manifest"]["manifest_version"]
	if checked_manifest_version <= 1:
		return false
	if checked_manifest_version > installed_manifest_version:
		return true
	var checked_mod_version = checked_mod_data[checked_mod_data.keys()[0]]["version_data"]["full_version_array"]
	var installed_mod_version = installed_dict["version_data"]["full_version_array"]
	if checked_mod_version[0] > installed_mod_version[0]:
		return true
	if checked_mod_version[1] > installed_mod_version[1]:
		return true
	if checked_mod_version[2] > installed_mod_version[2]:
		return true
	return false
