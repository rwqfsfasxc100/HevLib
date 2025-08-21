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

# open_download_page_on_OK will attempt to open the provided link from download_URL in the browser
# download_URL is intended to be a link to the download page of a mod
# For GitHub links, it's recommended to use the /releases/latest link - e.g. https://github.com/rwqfsfasxc100/HevLib/releases/latest
var open_download_page_on_OK : bool = false
var download_URL : String = ""





# Variable used to decide the query. Can be fetched if set to not close the game
var mod_exists : bool










# Main function body

func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS

	Debug.l("Mod Checker Script: starting check for mod [%s]" % mod_name)
	mod_exists = false
	var dir = Directory.new()
	var does = dir.file_exists(modmain_res_path)
	if does:
		if check_mod_version:
			for item in ModLoader.get_children():
				var script = item.get_script()
				var path = script.get_path()
				if path == modmain_res_path:
					var con = script.get_script_constant_map()
					var major = con.get("MOD_VERSION_MAJOR",1)
					var minor = con.get("MOD_VERSION_MINOR",0)
					var bugfix = con.get("MOD_VERSION_BUGFIX",0)
					
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
			mod_exists = true
	else:
		mod_exists = false
	if mod_exists:
		Debug.l("Mod Checker Script: %s exists and is running the correct version" % mod_name)
	else:
		get_tree().paused = true
		if show_dialogue_box:
			var box = AcceptDialog.new()
			box.connect("confirmed", self, "_confirmed_pressed")
			box.connect("popup_hide", self, "_popup_hide")
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
				if open_download_page_on_OK:
					bottom = bottom + "\n\nPress OK to open the downloads page."
				box.dialog_text = header + body + bottom
			else:
				box.dialog_text = custom_message_string
			box.visible = true
		else:
			_confirmed_pressed()
		pass

func _confirmed_pressed():
	Debug.l("Mod Checker Script: mod [%s] exists? [%s]" % mod_exists)
	if open_download_page_on_OK:
		Debug.l("Mod Checker Script: attempting to open downloads link @ [%s]" % download_URL)
		OS.shell_open(download_URL)
	_popup_hide()
	
onready var exit = Loader.prepare("res://Exit.tscn")

func _popup_hide():
	if not mod_exists and crash_if_not_found:
		Debug.l("Mod Checker Script: mod %s not found within desired version range, exiting game" % mod_name)
		Loader.go(exit)

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
			"version":{
				"version_major":1,
				"version_minor":0,
				"version_bugfix":0
			}
		}
		match manifest_version:
			2, 2.0:
				dict_template["version"]["version_major"] = manifest_data["package"].get("version_major",1)
				dict_template["version"]["version_minor"] = manifest_data["package"].get("version_minor",0)
				dict_template["version"]["version_bugfix"] = manifest_data["package"].get("version_bugfix",0)
				dict_template["version"]["version_metadata"] = manifest_data["package"].get("version_metadata","")
			2.1:
				dict_template["version"]["version_major"] = manifest_data["version"].get("version_major",1)
				dict_template["version"]["version_minor"] = manifest_data["version"].get("version_minor",0)
				dict_template["version"]["version_bugfix"] = manifest_data["version"].get("version_bugfix",0)
				dict_template["version"]["version_metadata"] = manifest_data["version"].get("version_metadata","")
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
