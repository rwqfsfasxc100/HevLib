# HevLib
Library mod for ΔV: Rings of Saturn that provides several useful functions

# Usage
## Instancing within a script
Each script requires the library to be loaded as a variant to be able to access the functions. The following script will have it loaded as a variant:
```
var HevLib = preload("res://HevLib/Functions.gd").new()
```
> [!NOTE]
> The variant can be called anywhere in a function, however to get access to it in the entire file, it's recommended to put it just below the extends statement

Once loaded into a function, it can be called by calling the variant's functions, with the syntax of `HevLib.__example_function`

Example script using the __array_to_string function from the library:
```
extends Node

var HevLib = preload("res://HevLib/Functions.gd").new()

func _ready():
  var array = ["this ", "is ", "an ", "example"]
  var string = HevLib.__array_to_string(array)
  return string
```
The script returns "this is an example" as a string

## Variable Node
A Node is added to the root after the Autoloads have been properly initialized, which provides a few variables that are used by some functions and can be helpful to get.

All variables can be fetched with the function `__get_lib_variables()`, and will provide a dictionary containing all variables. If it's optimal that only specific variables are fetched, they can be done manually by fetching the variable node through the following methods:

If your node is in the main scene tree, you can obtain access to it with the following variable:
```
var HevLibVariables = get_node("/root/HevLib~Variables")
```

If the node is not in the main tree, a small modification is needed to be used. Any autoload function can be used, just the ModLoader node is used for example. 
```
var HevLibVariables = ModLoader.get_node("/root/HevLib~Variables")
```

The node provides the following variables:
### AchievementData

* Returns a dictionary with four keys:
  * allAchievements is an array of names of all achievements currently in-game
  * unlockedAchievements is an array of names of all achievements currently unlocked in the achievements file
  * lockedAchievements is the inverse, listing the names of all locked achievements
  * stats are the names of all the current stats tracked, all with the stat: prefix
* Replaces the old functionality of the `__get_achievement_data()` function

### AchievementPercentageStats

* Returns an array of arrays containing the Steam completion percentages of achievements
* Each array is formatted as follows: [ACHIEVEMENT_NAME: String, PERCENTAGE: float]
* Has to wait for the Steam server to return the data, is Null otherwise

# Functions

> [!NOTE]
> All functions in the library use a double underscore prefix to make it easier to use with autocomplete. Typing `HevLib.__` should provide all available functions through it.

## __array_to_string(arr: Array) -> String
* Concatenates all parts of an array into a string
* Returns a string in the form of array[0] + array[1] + ... + array[n] etc.
 
## __get_zip_content(path: String, Strip_Parent_Folder: bool = false, To_Lower_Case: bool = false) -> Array
* Lists all files in the zip by paths relative to the mod's name folder
* i.e. a zip only containing a folder and a text file return [folder/, file.txt]
* Returns an array of file paths in zip-relative form, stored alphabetically
* Strip_Parent_Folder removes the first folder item before the slash.
* To_Lower_Case converts all characters to lower


## __fetch_file_from_zip(path: String, Destination_Folder_Path: String, Desired_File_Paths: Array) -> Array
* Loads a zip file and stores the requested files from paths relative to the root
* If you intend on taking data from a zip multiple times, this is a preferable method as it loads it to disk for future reference instead
* Does not work for fetching compressed data from within a zip (images, archives, .stex streams, etc)
* Defer to external programs for full unzip control
* Generates all folders in the zip file before handling the files to ensure they can save properly, but may cause clutter
* Outputs an array of all files saved to disk
* Handles case insensitivities

## __load_manifest_from_file(manifest: String) -> Dictionary
* Loads manifest data and returns it as a dictionary

## __load_file(modDir: String, zipDir: String, hasManifest: bool, manifestDirectory: String, hasIcon: bool, iconDir: String) -> String
* Specific function for Mod Menu behaviour
* modDir is the mod main's directory (form of res://Mod_Folder/ModMain.gd)
* zipDor is the directory of the mod's zip (form of mod_folder/mod.zip)
* hasManifest determines whether the manifest should be used
* manifestDirectory is the directory of the mod.manifest file (form of res://Mod_Folder/mod.manifest)
* hasIcon determines whether the custom mod icon should be used
* iconDir is the directory of the icon.stex file (form of res://Mod_Folder/icon.stex

## __get_mod_main(file: String, split_into_array: bool = false) -> String
* Returns 16 lines of text, split by a newline (\n), of mod data in a single string using the mod menu data standard
* Optional split_into_array bool converts the data into an array preemptively
* Preferable use of fetching mod data as it combines several of the previous helper functions into one, and removes the need for overhead code

## __check_folder_exists(folder: String) -> bool
* Ensures the supplied folder exists
* If folder exists, returns true
* Otherwise, attempts to create it. If it succeeds, returns true, else returns false

## __fetch_folder_files(folder: String, showFolders: bool = false, returnFullPath: bool = false) -> Array
* Returns the files in the supplied folder
* If showFolders is set to true, includes folders with the output

## __get_file_content(file: String) -> String
* Returns the content from a file as a string

## __get_first_file(folder: String) -> String
* Supplies the first file in a folder
* If no files exists, returns false

## __recursive_delete(path: String)
* Recursively deletes the provided folder
* Returns false if the folder doesn't load

## __format_for_large_numbers(num: int) -> String:
* Formats numbers into a human-readable form, separated with a comma

## [__webtranslate(URL: String):](https://github.com/rwqfsfasxc100/HevLib/wiki/__webtranslate)
* Loads translations from a given Gihub repository
* Has to be specifically a repository link
* E.G. https://github.com/rwqfsfasxc100/HevLib

## __webtranslate_reset(URL: String) -> bool
* Clears the translation cache of a provided URL
* Returns true if succeeded, false if it didn't

## __get_achievement_data(achievementID: String) -> Dictionary
* Gets the data of a provided achievement by it's ID
* Returns a dictionary with 7 keys:
* name = the achievement's ID for convenience
* isUnlocked = boolean for whether the achievement is unlocked or not
* stat = associated stat name, w/o the stat: prefix
* limit = the stat's unlocking threshhold
* data = any additional data that might be useful to provide. 
  * currently only provides the ship/equipment names of playtime achievements in untranslated form
* rare = based on whether the game considers an achievement rare
* spoiler = whether the achievement is considered a spoilered achievement on steam. 
  * manually inputted data, so may be missing data in the days following an update that adds achievements

## __get_lib_variables() -> Object
* Returns HevLib variables
* Has to be done on ready, as it relies upon the Autoloads having finished loading
* Some variables may take longer to load as they are fetched from the internet

## __webtranslate_timed(URL: String, MINUTES_DELAY: int = 30)
* Similar function to __webtranslate, however performs the task repetitively
* URL is the same as the URL string for __webtranslate
* Optional MINUTES_DELAY integer is the delay between runs of the __webtranslate tool
  * Defaults to 30 minutes if left blank
* Cannot be called as early as `_webtranslate`, as it requires the Variable node to have been added, which in of itself requires the Autoloads to have been completely initialized
  * Using a timer to wait a couple of seconds should counter this issue

# Depreciated Functions
These are functions that exist on older versions, and are kept for the sake of documentation

## __get_current_achievements() -> Dictionary (V.1.2.1 only)
* Fetches and returns data from the achievement file
* Returns a dictionary with four keys:
* allAchievements is an array of names of all achievements currently in-game
* unlockedAchievements is an array of names of all achievements currently unlocked in the achievements file
* lockedAchievements is the inverse, listing the names of all locked achievements
* stats are the names of all the current stats tracked, all with the stat: prefix

* Replaced with the first index of the variable node data
