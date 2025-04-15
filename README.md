# HevLib
Library mod for ΔV: Rings of Saturn that provides several useful functions.

This library is run through a set of 'pointers', which are small snippets of code that act, like the namesake, as pointers towards each function's file and as a way to organize a larger number of features into an easy to access location.

# Usage
Each pointer is found within the dedicated pointer folder at `res://HevLib/pointers/`, and can be called as a variant through means such as the following:
```
var FileAccess = preload("res://HevLib/pointers/FileAccess.gd").new()
```
> [!NOTE]
> The pointer variants can be called anywhere in a function, however to get access to it in the entire file, it's recommended to put it just below the extends statement

Once loaded into a function, it can be called by calling the variant's functions, with the syntax of `Pointer.__example_function`

Example script using the __array_to_string function from the library:
```
extends Node

var DataFormat = preload("res://HevLib/pointers/DataFormat.gd").new()

func _ready():
  var array = ["this ", "is ", "an ", "example"]
  var string = DataFormat.__array_to_string(array)
  return string
```
The script returns "this is an example" as a string

> [!NOTE]
> All functions in the library use a double underscore prefix to make it easier to use with autocomplete. Typing `__` after any pointer variant should provide all available functions through it.

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

# HevLib Library-Specific Pointer

A pointer exists in the folder to purely aide with the development of mods with it, being located at `res://HevLib/pointers/HevLib.gd`. It's purpose is to provide information about the library to reduce the need for mod developers to go back to documentation or look at the files themselves. Many of these use the `developer_hint` variant you may have seen if you delved into the pointers yourself.

This pointer can be accessed like any other pointer would, and provides the following functions:
* `__get_lib_variables()` - Likely the only function useful outside of information on the library, this fetches all data from the library's variable node at the time it was run.
* `__get_lib_pointers(return_as_full_path: bool = false)` - returns an array of the pointer filenames, with the optional boolean converting them to full res:// paths
* `__get_pointer_functions(pointer: String)` - returns the function list of a pointer. Pointer string can be any level of accessing the pointer (just filename, or partial / full paths to it), however it needs the exact filename and extension (e.g. `FileAccess.gd`)
* `__get_library_functionality` - returns a dictionary containing `__get_pointer_functions` being iterated on all pointers from `__get_lib_pointers`. Useful if you want everything at once
