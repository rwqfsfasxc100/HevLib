extends Node

# Concatenates all parts of an array into a string
# Returns a string in the form of array[0] + array[1] + ... + array[n] etc.
static func __array_to_string(arr: Array) -> String:
	var f = load("res://HevLib/globals/array_to_string.gd").new()
	var s = f.array_to_string(arr)
	return s

# Lists all files in the zip by paths relative to the mod's name folder
# i.e. a zip only containing a folder and a text file return [folder/, file.txt]
# Returns an array of file paths in zip-relative form, stored alphabetically
# Strip_Parent_Folder removes the first folder item before the slash.
# To_Lower_Case converts all characters to lower
static func __get_zip_content(path: String, Strip_Parent_Folder: bool = false, To_Lower_Case: bool = false) -> Array:
	var f = load("res://HevLib/globals/get_zip_content.gd").new()
	var s = f.get_zip_content(path, Strip_Parent_Folder, To_Lower_Case)
	return s

# Loads a zip file and stores the requested files from paths relative to the root
# If you intend on taking data from a zip multiple times, this is a preferable method as it loads it to disk for future reference instead
# Does not work for fetching compressed data from within a zip (images, archives, .stex streams, etc)
# Defer to external programs for full unzip control
# Generates all folders in the zip file before handling the files to ensure they can save properly, but may cause clutter
# Outputs an array of all files saved to disk
# Handles case insensitivities
static func __fetch_file_from_zip(path: String, Destination_Folder_Path: String, Desired_File_Paths: Array) -> Array:
	var f = load("res://HevLib/globals/fetch_file_from_zip.gd").new()
	var s = f.fetch_file_from_zip(path, Destination_Folder_Path, Desired_File_Paths)
	return s

# Loads manifest data and returns it as a dictionary
static func __load_manifest_from_file(manifest: String) -> Dictionary:
	var f = load("res://HevLib/globals/load_manifest_from_file.gd").new()
	var s = f.load_manifest_from_file(manifest)
	return s

# Specific function for Mod Menu behaviour
# modDir is the mod main's directory (form of res://Mod_Folder/ModMain.gd)
# zipDor is the directory of the mod's zip (form of mod_folder/mod.zip)
# hasManifest determines whether the manifest should be used
# manifestDirectory is the directory of the mod.manifest file (form of res://Mod_Folder/mod.manifest)
# hasIcon determines whether the custom mod icon should be used
# iconDir is the directory of the icon.stex file (form of res://Mod_Folder/icon.stex
static func __load_file(modDir: String, zipDir: String, hasManifest: bool, manifestDirectory: String, hasIcon: bool, iconDir: String) -> String:
	var f = load("res://HevLib/globals/load_file.gd").new()
	var s = f.load_file(modDir, zipDir, hasManifest, manifestDirectory, hasIcon, iconDir)
	return s

# Returns 16 lines of text, split by a newline (\n), of mod data in a single string using the mod menu data standard
# Optional split_into_array bool converts the data into an array preemptively
static func __get_mod_main(file: String, split_into_array: bool = false) -> String:
	var f = load("res://HevLib/globals/get_mod_main.gd").new()
	var s = f.get_mod_main(file, split_into_array)
	return s

# Ensures the supplied folder exists
# If folder exists, returns true
# Otherwise, attempts to create it. If it succeeds, returns true, else returns false
static func __check_folder_exists(folder: String) -> bool:
	var f = load("res://HevLib/globals/check_folder_exists.gd")
	var s = f.check_folder_exists(folder)
	return s

# Returns the files in the supplied folder
# If showFolders is set to true, includes folders with the output
# If ReturnFullPath is set to true, returns the complete path of the folder's contents, not just relative
static func __fetch_folder_files(folder: String, showFolders: bool = false, returnFullPath: bool = false) -> Array:
	var f = load("res://HevLib/globals/fetch_folder_files.gd")
	var s = f.fetch_folder_files(folder, showFolders, returnFullPath)
	return s

# Returns the content from a file as a string
static func __get_file_content(file: String) -> String:
	var f = load("res://HevLib/globals/get_file_content.gd")
	var s = f.get_file_content(file)
	return s

# Supplies the first file in a folder
# If no files exists, returns false
static func __get_first_file(folder: String) -> String:
	var f = load("res://HevLib/globals/get_first_file.gd")
	var s = f.get_first_file(folder)
	return s

# Recursively deletes the provided folder
# Returns false if the folder doesn't load
static func __recursive_delete(path: String):
	Debug.l("HevLib: function 'recursive_delete' started on @%s" % path)
	var f = load("res://HevLib/globals/recursive_delete.gd")
	var s = f.recursive_delete(path)
	return s

# formats numbers into a human-readable form, separated with a comma
static func __format_for_large_numbers(num: int) -> String:
	var f = load("res://HevLib/globals/format_for_large_numbers.gd")
	var s = f.format_for_large_numbers(num)
	return s

# Loads translations from a given Gihub repository
# Has to be specifically a repository link
# E.G. https://github.com/rwqfsfasxc100/HevLib
static func __webtranslate(URL: String):
	var f = load("res://HevLib/webtranslate/webtranslate.gd")
	f.webtranslate(URL)

# Clears the translation cache of a provided URL
# Returns true if succeeded, false if it didn't
static func __webtranslate_reset(URL: String) -> bool:
	var f = load("res://HevLib/webtranslate/webtranslate_reset.gd")
	var s = f.webtranslate_reset(URL)
	return s

# Gets the data of a provided achievement by it's ID
# Returns a dictionary with 7 keys:
# name = the achievement's ID for convenience
# isUnlocked = boolean for whether the achievement is unlocked or not
# stat = associated stat name, w/o the stat: prefix
# limit = the stat's unlocking threshhold
# data = any additional data that might be useful to provide. 
  # currently only provides the ship/equipment names of playtime achievements in untranslated form
# rare = based on whether the game considers an achievement rare
# spoiler = whether the achievement is considered a spoilered achievement on steam. 
  # manually inputted data, so may be missing data in the days following an update that adds achievements
static func __get_achievement_data(achievementID: String) -> Dictionary:
	var f = load("res://HevLib/achievements/get_achievement_data.gd")
	var s = f.get_achievement_data(achievementID)
	return s

# Returns HevLib variables
# Has to be done on ready, as it relies upon the Autoloads having finished loading
# Some variables may take longer to load as they are fetched from the internet
static func __get_lib_variables() -> Object:
	var f = load("res://HevLib/globals/get_lib_variables.gd").new()
	var s = f.get_lib_variables()
	return s

# Similar function to __webtranslate, however performs the task repetitively
# URL is the same as the URL string for __webtranslate
# Optional MINUTES_DELAY integer is the delay between runs of the __webtranslate tool
  # Defaults to 30 minutes if left blank
static func __webtranslate_timed(URL: String, MINUTES_DELAY: int = 30):
	var f = load("res://HevLib/webtranslate/webtranslate_timed.gd").new()
	var s = f.webtranslate_timed(URL, MINUTES_DELAY)

# Supplies all subsidual nodes of a node in an array
# Node input is the node to get all children of
# Optional strip_supplied_node_from_array used to ignore the supplied node in the output
# Optional return_only_paths used to provide only NodePaths in the array
# Optional use_relative_paths used to strip any path prefixes of node paths, 
  # requires return_only_paths to work
static func __get_all_children(node, strip_supplied_node_from_array = false, return_only_paths = false, use_relative_paths = false):
	var f = load("res://HevLib/globals/get_all_children.gd").new()
	var s = f.get_all_children(node, strip_supplied_node_from_array, return_only_paths, use_relative_paths)
	return s

static func __get_stat_data(stat: String) -> int:
	var f = load("res://HevLib/achievements/get_stat_data.gd")
	var s = f.get_stat_data(stat)
	return s
