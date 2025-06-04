extends Node

var developer_hint = {
	"__get_mod_data":[
		
	]
}

static func __get_mod_data() -> Dictionary:
	var mods = ModLoader.get_children()
	var mod_dictionary = {}
	for mod in mods:
		var script_path = mod.get_script().get_path()
		var mod_priority = mod.get("MOD_PRIORITY",0)
		var mod_name = mod.get("MOD_NAME",script_path.split("/")[2])
		var legacy_mod_version = mod.get("MOD_VERSION","1.0.0")
		var mod_version_major = mod.get("MOD_VERSION_MAJOR",1)
		var mod_version_minor = mod.get("MOD_VERSION_MINOR",0)
		var mod_version_bugfix = mod.get("MOD_VERSION_BUGFIX",0)
		var mod_version_metadata = mod.get("MOD_VERSION_METADATA","")
		var mod_version_array = [mod_version_major,mod_version_minor,mod_version_bugfix]
		var mod_version_string = str(mod_version_major) + "." + str(mod_version_minor) + "." + str(mod_version_bugfix)
		if not mod_version_metadata == "":
			mod_version_array.append(mod_version_metadata)
			mod_version_string = mod_version_string + "-" + mod_version_metadata
		var mod_is_library = mod.get("MOD_IS_LIBRARY",false)
		var version_dictionary = {"version_major":mod_version_major,"version_minor":mod_version_minor,"version_bugfix":mod_version_bugfix,"version_metadata":mod_version_metadata,"full_version_array":mod_version_array,"full_version_string":mod_version_string,"legacy_mod_version":legacy_mod_version}
		var mod_entry = {str(script_path):{"name":mod_name,"priority":mod_priority,"version_data":version_dictionary,"is_a_library":mod_is_library,"node":mod}}
		mod_dictionary.merge(mod_entry)
	var statistics = {"installed_mod_count":mods.size()}
	var returnValues = {"mods":mod_dictionary,"statistics":statistics}
	return returnValues
