extends Node

# This script can be copied into any mod and loaded to check for HevLib, or any other mod desired
# Upon being loaded, it will automatically run and perform the check for the desired mod
# Run the script by instancing it as such:
# var mod_check = load("res://path/to/script/hevlib_check.gd").new() 
# If the variable crash_if_not_found is set to false, the result of the query can be found by fetching the mod_exists variable from the variable
# var mod_exists = mod_check.mod_exists


# The display name of the mod the script is checking for, used by the dialogue box text and for logging
var mod_name : String = "HevLib"

# The display name of the mod using this script, so the user knows which mod the requirement is for
var this_mod_name : String = "Example Mod"

# The minimum and maximum versions of the mod that would be considered valid. 
# Anything below the min and anything above the max will cause a failed query
# mod.manifest must be standardized to at least manifest version 2 to be treated as a valid version source
# If no manifest exists, or the manifest version is either below 2 or is not stated, versioning in the ModMain.gd script requires the following int variables: MOD_VERSION_MAJOR, MOD_VERSION_MINOR, and MOD_VERSION_BUGFIX
# If neither the manifest or mod main have proper versioning, the check automatically fails
# Setting INF for the max major version and -INF for the min major version will act as standard operators and mean that no maximum or no minimum is set respectively
# 
var min_version_major : int = 1 # Setting this to -INF will mean no min version is checked
var min_version_minor : int = 0
var min_version_bugfix : int = 0

var max_version_major : int = 4 # Setting this to INF will mean no max version is checked
var max_version_minor : int = 2
var max_version_bugfix : int = 0

var check_mod_version : bool = true

# Whether to display a confirmation dialogue box to say that the mod is missing
# Will use a default message and mod name if the custom_message_string variable is left blank as ""
# dialogue_box_title sets text to be displayed at the top of the box
var show_dialogue_box : bool = true
var dialogue_box_title : String = ""

# If true, the game will close after either the dialogue box is closed, or if show_dialogue_box is false, immediately after the query fails
# If no dialogue box is used, there will be extra logging performed to make sure that the issue is made very clear.
var crash_if_not_found : bool = true

# The file path to the mod main file. The file structure is equivalent to the file structure of the zip file.
var modmain_res_path : String = "res://HevLib/ModMain.gd"

# A custom message that can be used for the dialogue box if enabled.
# Can be both raw text or a translation string, however do make sure that the translation is loaded before this script runs
# This will not use the mod_name string for display, so please make sure to include it in the string
var custom_message_string : String = ""







# Variable used to decide the query. Can be fetched if set to not close the game
var mod_exists : bool










# Main function body

func _ready():
	Debug.l("Mod Checker Script: starting check for mod [%s]" % mod_name)
	mod_exists = false
	var dir = Directory.new()
	var does = dir.file_exists(modmain_res_path)
	if does:
		for item in ModLoader.get_children():
			var script = item.get_script()
			var path = script.get_path()
			if path == modmain_res_path:
				var con = script.get_script_constant_map()
				var major = con.get("MOD_VERSION_MAJOR",1)
				var minor = con.get("MOD_VERSION_MINOR",0)
				var bugfix = con.get("MOD_VERSION_MBUGFIX",0)
				
				var fsplit = modmain_res_path.split(modmain_res_path.split("/")[modmain_res_path.split("/").size() - 1])
				var parent_folder = modmain_res_path.split(fsplit)[0]
				var array = fetch_folder_files(parent_folder)
				for file in array:
					if file.to_lower() == "mod.manifest":
						var dictionary = parse_as_manifest(file, true)
						
						major = dictionary["version"]["version_major"]
						minor = dictionary["version"]["version_minor"]
						bugfix = dictionary["version"]["version_bugfix"]
						
				if min_version_major > major or major > max_version_major:
					mod_exists = false
				if min_version_minor > minor or minor > max_version_minor:
					mod_exists = false
				if min_version_bugfix > bugfix or bugfix > max_version_bugfix:
					mod_exists = false
	else:
		mod_exists = false
	if mod_exists:
		Debug.l("Mod Checker Script: %s exists and is running the correct version" % mod_name)
	else:
		if show_dialogue_box:
			var box = AcceptDialog.new()
			box.connect("confirmed", self, "_confirmed_pressed")
			box.window_title = dialogue_box_title
			box.popup_exclusive = true
			box.rect_min_size = Vector2(300,150)
			
			if custom_message_string == "":
				var text = ""
				var header = "Warning! The mod %s is not currently installed with the correct version.\n\n" % mod_name
				var body = "Please install a copy of %s that is " % mod_name
				var mx = false
				if not max_version_major == INF:
					mx = true
					var txt = "older than version %s.%s.%s" % [max_version_major,max_version_minor,max_version_bugfix]
					body = body + txt
				
				if not min_version_major == -INF:
					if mx:
						body = body + " or is "
					var txt = "newer than version %s.%s.%s" % [min_version_major,min_version_minor,min_version_bugfix]
					body = body + txt
				var bottom = ". \n\nPlease ensure that the mod was downloaded from the correct page, for instance the releases page on GitHub."
				box.dialog_text = header + body + bottom
			else:
				box.dialog_text = custom_message_string
			box.visible = true
		else:
			_confirmed_pressed()
		pass

func _confirmed_pressed():
	Debug.l("Mod Checker Script: mod [%s] exists? [%s]" % mod_exists)
	
	if not mod_exists and crash_if_not_found:
		Debug.l("Mod Checker Script: mod %s not found within desired version range, exiting game" % mod_name)
		Loader.go(exit)
	
onready var exit = Loader.prepare("res://Exit.tscn")


static func fetch_folder_files(folder) -> Array:
	var fileList = []
	var dir = Directory.new()
#	folder = ProjectSettings.localize_path(folder)
	var does = dir.dir_exists(folder)
	if not does:
		return []
	dir.open(folder)
	var dirName = dir.get_current_dir()
	dir.list_dir_begin(true)
	while true:
		var fileName = dir.get_next()
		var capture = true
		if fileName.ends_with("/"):
			capture = false
		if fileName == "." or fileName == "..":
			capture = false
		if capture:
			dirName = dir.get_current_dir()
			Debug.l(fileName)
			if fileName == "":
				break
			if dir.current_is_dir():
				continue
			fileList.append(fileName)
	var dFiles = ""
	for m in fileList:
		if dFiles == "":
			dFiles = m
		else:
			dFiles = dFiles + ", " + m
	return fileList


func parse_as_manifest(file_path: String, format_to_manifest_version: bool = false, collect_legacy_values: bool = false) -> Dictionary:
	
	var cfg = config_parse(file_path)
	var manifest_data : Dictionary = {}
	var manifest_version = 1
#	var fsplit = file_path.split(file_path.split("/")[file_path.split("/").size() - 1])
#	var parent_folder = file_path.split(fsplit)[0]
	if "manifest_definitions" in cfg.keys():
		manifest_version = cfg["manifest_definitions"].get("manifest_version",manifest_version)
		if not manifest_version is float or not manifest_version is int:
			manifest_version = 1
	manifest_data = cfg
	if format_to_manifest_version:
		var dict_template = {
			"mod_information":{
				"name":null,
				"id":null,
				"description":"",
				"author":"",
				"credits":[]
			},
			"version":{
				"version_major":1,
				"version_minor":0,
				"version_bugfix":0,
				"version_metadata":"",
				"version_string":"1.0.0"
			},
			"tags":{
				"adds_equipment":[],
				"adds_events":[],
				"adds_gameplay_mechanics":[],
				"adds_ships":[],
				"allow_achievements":false,
				"fun":false,
				"handle_extra_crew":24,
				"is_library_mod":false,
				"library_hidden_by_default":true,
				"overhaul":false,
				"quality_of_life":false,
				"uses_hevlib_research":false,
				"visual":false
			},
			"links":{
				"github":{"link":"","has_releases":false},
				"discord":"",
				"nexus":"",
				"donations":"",
				"wiki":"",
				"custom_links":{}
			}
		}
		match manifest_version:
			1, 1.0:
				dict_template["mod_information"]["id"] = manifest_data["package"].get("id",null)
				dict_template["mod_information"]["name"] = manifest_data["package"].get("name",null)
				var version = manifest_data["package"].get("version","unknown")
				dict_template["mod_information"]["description"] = manifest_data["package"].get("description","MODMENU_DESCRIPTION_PLACEHOLDER")
				var group = manifest_data["package"].get("group","")
				var github_releases = manifest_data["package"].get("github_releases","")
				
				var d = false
				if not github_releases == "":
					d = true
				dict_template["links"]["github"] = {"link":manifest_data["package"].get("github_homepage",""),"has_releases":d}
				
				dict_template["links"]["discord"] = manifest_data["package"].get("discord_thread","")
				dict_template["links"]["nexus"] = manifest_data["package"].get("nexus_page","")
				dict_template["links"]["donations"] = manifest_data["package"].get("donations_page","")
				dict_template["links"]["wiki"] = manifest_data["package"].get("wiki_page","")
				var custom_link = manifest_data["package"].get("custom_link","")
				var custom_link_name = manifest_data["package"].get("custom_link_name","")
				
				if collect_legacy_values:
					var dict = {"legacy":{"manifest_version":1,"version":version,"group":group,"github_releases":github_releases,"custom_link":custom_link,"custom_link_name":custom_link_name}}
					dict_template.merge(dict)
			2, 2.0:
				dict_template["mod_information"]["id"] = manifest_data["package"].get("id",null)
				dict_template["mod_information"]["name"] = manifest_data["package"].get("name",null)
				dict_template["version"]["version_major"] = manifest_data["package"].get("version_major",1)
				dict_template["version"]["version_minor"] = manifest_data["package"].get("version_minor",0)
				dict_template["version"]["version_bugfix"] = manifest_data["package"].get("version_bugfix",0)
				dict_template["version"]["version_metadata"] = manifest_data["package"].get("version_metadata","")
				dict_template["mod_information"]["description"] = manifest_data["package"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER")
				var groups = manifest_data["package"].get("groups",[])
				dict_template["links"]["github"] = {"link":manifest_data["package"].get("github",""),"has_releases":manifest_data["package"].get("link_github_releases",false)}
				dict_template["links"]["discord"] = manifest_data["package"].get("discord_thread","")
				dict_template["links"]["nexus"] = manifest_data["package"].get("nexus_page","")
				dict_template["links"]["donations"] = manifest_data["package"].get("donations_page","")
				dict_template["links"]["wiki"] = manifest_data["package"].get("wiki_page","")
				var custom_data = manifest_data["package"].get("custom_data",[])
				dict_template["mod_information"]["author"] = manifest_data["package"].get("author","Unknown")
				dict_template["mod_information"]["credits"] = manifest_data["package"].get("credits",[])
				
				if collect_legacy_values:
					var dict = {"legacy":{"manifest_version":2,"groups":groups,"custom_data":custom_data}}
					dict_template.merge(dict)
			2.1:
				# information
				dict_template["mod_information"]["id"] = manifest_data["mod_information"].get("manifest_id",null)
				dict_template["mod_information"]["name"] = manifest_data["mod_information"].get("name",null)
				dict_template["mod_information"]["description"] = manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER")
				dict_template["mod_information"]["author"] = manifest_data["mod_information"].get("author","Unknown")
				dict_template["mod_information"]["credits"] = manifest_data["mod_information"].get("credits",[])
				
				# versioning
				dict_template["version"]["version_major"] = manifest_data["version"].get("version_major",1)
				dict_template["version"]["version_minor"] = manifest_data["version"].get("version_minor",0)
				dict_template["version"]["version_bugfix"] = manifest_data["version"].get("version_bugfix",0)
				dict_template["version"]["version_metadata"] = manifest_data["version"].get("version_metadata","")
				
				# tags
				dict_template["tags"]["allow_achievements"] = manifest_data["tags"].get("allow_achievements",false)
				dict_template["tags"]["adds_ships"] = manifest_data["tags"].get("adds_ships",[])
				dict_template["tags"]["adds_equipment"] = manifest_data["tags"].get("adds_equipment",[])
				dict_template["tags"]["quality_of_life"] = manifest_data["tags"].get("quality_of_life",false)
				dict_template["tags"]["is_library_mod"] = manifest_data["tags"].get("is_library_mod",false)
				dict_template["tags"]["adds_gameplay_mechanics"] = manifest_data["tags"].get("adds_gameplay_mechanics",[])
				dict_template["tags"]["uses_hevlib_research"] = manifest_data["tags"].get("uses_hevlib_research",false)
				dict_template["tags"]["overhaul"] = manifest_data["tags"].get("overhaul",false)
				dict_template["tags"]["adds_events"] = manifest_data["tags"].get("adds_events",[])
				dict_template["tags"]["handle_extra_crew"] = manifest_data["tags"].get("handle_extra_crew",24)
				dict_template["tags"]["visual"] = manifest_data["tags"].get("visual",false)
				dict_template["tags"]["fun"] = manifest_data["tags"].get("fun",false)
				
				# links
				dict_template["links"]["github"] = manifest_data["links"].get("github",{"link":"","has_releases":false})
				dict_template["links"]["discord"] = manifest_data["links"].get("discord","")
				dict_template["links"]["nexus"] = manifest_data["links"].get("nexus","")
				dict_template["links"]["donations"] = manifest_data["links"].get("donations","")
				dict_template["links"]["wiki"] = manifest_data["links"].get("wiki","")
				dict_template["links"]["custom_links"] = manifest_data["links"].get("custom_links",{})
				
		var version_metadata = dict_template["version"]["version_metadata"]
		var version_string = dict_template["version"]["version_major"] + "." + dict_template["version"]["version_minor"] + "." + dict_template["version"]["version_bugfix"]
		if not version_metadata == "":
			version_string = version_string + "-" + version_metadata
		dict_template["version"]["version_string"] = version_string
		
		return dict_template
	return manifest_data

func config_parse(file):
	var f2 = File.new()
	f2.open(file,File.READ)
	var txt = f2.get_as_text()
	f2.close()
	var cfg = ConfigFile.new()
	cfg.parse(txt)
	var cfg_sections = cfg.get_sections()
	var cfg_dictionary = {}
	for section in cfg_sections:
		var data = {}
		var keys = cfg.get_section_keys(section)
		for key in keys:
			var item = cfg.get_value(section,key)
			data.merge({key:item})
		cfg_dictionary.merge({section:data})
	return cfg_dictionary


