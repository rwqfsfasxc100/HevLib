extends Reference

class Achievements:
	const description = "Helper functions to fetch achievement and stat data"
	const methods = {
		"__get_achievement_data":{
			"description":"Fetches information regarding a specific achievement",
			"args":[
				"achievementID -> (String) achievement ID to fetch the data of."
			],
			"return":[
				"Dictionary with the following formatting:",
				" name (String) -> the achievement name. Identical to the achievementID arg.",
				" isUnlocked (bool) -> whether the achievement is registered as unlocked.",
				" stat (String/null) -> if the achievement has a respective stat. Will be null if it does not.",
				" limit (int/float/null) -> if the achievement has a stat, will be the required value of the stat for the achievement to be earned. Will be null if it doesn't have a stat",
				" data (Array/null) -> if the achievement has additional information, will be provided through an array. currently only used by playtime achievements to list the required ships/equipment to earn the achievement, and if not will be null",
				" rare (bool) -> whether the achievement is considered to be rare by the game",
				" spoiler (bool) -> whether the achievement is spoilered on Steam",
			],
		},
		"__get_stat_data":{
			"description":"Fetches information regarding a specific stat.",
			"args":[
				"STAT (String) -> The stat to fetch. If it does not start with 'stat:', it will be added to make sure that it can be fetched."
			],
			"return":[
				"Integer or float for the value of the stat"
			]
		},
		"__get_achievement_percentage":{
			"description":"Provides your current achievement completion percentage",
			"return":[
				"Float for the completion percentage out of 100"
			]
		},
		"__get_current_achievements":{
			"description":"Provides a dictionary containing all achievement and stat data",
			"return":[
				"Dictionary containing all achievement-adjacent information",
				" allAchievements (Array) -> the names of all achievements currently registered by the game",
				" unlockedAchievements (Array) -> the names of all currently achieved achievements",
				" lockedAchievements (Array) -> the names of all locked achievements",
				" stats (Array) -> the names of all stats currently with earned values. Not all stats may be registered",
			]
		},
		"__get_steam_achievement_percentages":{
			"description":"Provides a dictionary containing every achievement with the Steam unlock percentage as it's key",
			"return":[
				"Dictionary containing every achievement with the Steam unlock percentage as it's key"
			]
		},
	}
class ConfigDriver:
	const description = "Provides functions that unify and handle a configuration system for mods"
	const methods = {
				"__store_config":{
					"description":"Stores an entire dictionary's worth of data inside a config. Will override settings if they already exist, otherwise will be added to the config.",
					"args":[
						"configuration -> (Dictionary) providing the configs. Must be at least three levels deep to cover sections, keys, and their values (i.e. {'section':{'setting_1':true,'setting_2':false}})",
						"mod_id -> (String) providing the mod/identifier to store the config behind. Cannot contain forward slashes (/) or spaces ( ), and these will be removed when being processed.",
						"cfg_filename (optional) -> (String) used for the file this config is stored in within the 'user://cfg/' folder. Defaults to 'Mod_Configurations.cfg'"
					],
				},
				"__store_value":{
					"description":"Stores an individual setting to the config.",
					"args":[
						"mod_id -> (String) providing the mod/identifier to store the config to. Cannot contain forward slashes (/) or spaces ( ), and these will be removed when being processed.",
						"section -> (String) for the config's section to store under",
						"key -> (String) for the setting value to store.",
						"value -> The value being stored to the config.",
						"cfg_filename (optional) -> (String) used for the file this config is stored in within the 'user://cfg/' folder. Defaults to 'Mod_Configurations.cfg'"
					],
				},
				"__get_config":{
					"description":"Fetches the entire config dictionary for a given mod/identifier",
					"args":[
						"mod_id -> (String) providing the mod/identifier to fetch the config from. Cannot contain forward slashes (/) or spaces ( ), and these will be removed when being processed.",
						"cfg_filename (optional) -> (String) used for the file this config is stored in within the 'user://cfg/' folder. Defaults to 'Mod_Configurations.cfg'"
					],
					"return":[
						"Dictionary containing the entire config."
					]
				},
				"__get_value":{
					"description":"Fetches an individual setting and returns it's value",
					"args":[
						"mod_id -> (String) providing the mod/identifier to fetch the config from. Cannot contain forward slashes (/) or spaces ( ), and these will be removed when being processed.",
						"section -> (String) for the config's section to fetch from.",
						"key -> (String) for the setting value to get.",
						"default (optional) -> (Variant) a default value to return if the config doesn't exist. Defaults to null",
						"cfg_filename (optional) -> (String) used for the file this config is stored in within the 'user://cfg/' folder. Defaults to 'Mod_Configurations.cfg'"
					],
					"return":[
						"Variant from the setting. Indeterminable from a documentation standpoint."
					]
				},
				"__establish_connection":{
					"description":"Connects a method within an object to be called whenever the config changes",
					"args":[
						"method -> (String) method name to be called when the config changes",
						"node -> (Object) the object that will be receiving the method call",
						"type (optional) -> (String) for the connection mode. Accepts the following: config -> will update whenever the config changes; input -> will update only whenever an input-type config changes; both -> connects with both type, but has to use a separate method to connect the input type due to technical limitations",
						"input_method (optional) -> (String) for the method name the input change uses when `type` is set to `both`. Even if using the default method name, this should at least be defined when calling this to help readability. Defaults to 'input_changed'.",
					],
				},
				"__remove_connection":{
					"description":"Disconnects any connections made by __establish_connection, using the same operands",
					"args":[
						"method -> (String) method name that the object has been connected to",
						"node -> (Object) the object that would have been receiving the method call",
						"type (optional) -> (String) for the connection mode. Accepts the following: config -> will update whenever the config changes; input -> will update only whenever an input-type config changes; both -> connects with both type, but has to use a separate method to connect the input type due to technical limitations",
						"input_method (optional) -> (String) for the method name the input change used when connected to the `both` type, and needs to be used if `both` was ever used to connect. Defaults to 'input_changed'",
					],
				},
				"__load_configs":{
					"description":"Internal method used to initialize a configuration file. Only use if you know what you're doing",
					"args":[
						"cfg_filename (optional) -> (String) used for the file this config is stored in within the 'user://cfg/' folder. Defaults to 'Mod_Configurations.cfg'"
					],
				},
				"__load_inputs_from_string_array":{
					"description":"Creates input action events for a specific action based on an array of strings for key names",
					"args":[
						"key -> (String) used for the action event name to add the events behind",
						"strings -> (Array) used for the input events. Mouse events are prefixed with `Mouse X`; joy button events are prefixed with `JoyButton X`, and joy axis events are prefixed with `JoyAxis X`. Joy axis events can have their number be negative to trigger it in the opposite direction. Anything not using those prefixes will be handled as keyboard inputs.",
					],
				},
				"__change_made":{
					"description":"Marks the config as needing to be saved on the next physics frame.",
				},
				"__subscribed_changes":{
					"description":"Internal method used to process any changes for objects subscribed to a setting change",
				},
				"__input_change_made":{
					"description":"Internal method used to process any changes made specifically to input type configs",
				},
				"__subscribe_to_setting_change":{
					"description":"Connects an object to call a method when a specific setting has been changed",
					"args":[
						"method -> (String) for the method to connect to",
						"object -> (Object) to connect to for the method call",
						"id -> (String) mod/identifier for the config to check",
						"section -> (String) the config section to get the setting from",
						"setting -> (String) the specific setting to check against"
					]
				},
				"__disconnect_subscription":{
					"description":"Disconnects any established subscriptions made for a setting",
					"args":[
						"method -> (String) for the method to connect to",
						"object -> (Object) to connect to for the method call",
						"id -> (String) mod/identifier for the config to check",
						"section -> (String) the config section to get the setting from",
						"setting -> (String) the specific setting to check against"
					]
				},
				"__get_minmax_string_from_dict":{
					"description":"Creates a string for a mod from a dictionary, with possible versions shown if provided",
					"args":[
						"requirement -> (Dictionary) containing the mod data. MUST have `mod_id` for the mod ID string, can also have `minimum_version`/`min_version` for the minimum mod version, or `maximum_version`/`max_version` for the maximum mod version"
					],
					"return":[
						"String containing the mod's data"
					]
				},
				"__truncate_mod_id":{
					"description":"Formats a string as if it were being handled as a config mod/identifier, stripping out all spaces and forward slashes",
					"args":[
						"mod_id -> (String) used for the formatted mod/identifier"
					],
					"return":[
						"String formatted to a mod id"
					]
				},
				"__truncate_section":{
					"description":"Formats a string for sections by stripping out forward slashes",
					"args":[
						"section -> (String) used for formatting"
					],
					"return":[
						"String formatted to a section name"
					]
				},
				"__truncate_to_setting_entry":{
					"description":"Converts a mod/identifier and section to fetch the config by it's internal name. Formatting is handled by the method, so inputs do not need to be sanitized",
					"args":[
						"mod_id -> (String) used for the formatted mod/identifier",
						"section -> (String) used for formatting"
					],
					"return":[
						"String formatted by mod_id/section, with all other parts cut out."
					]
				},
				"__validate_dictionary":{
					"description":"Checks a dictionary for any config and mod limitations to see if it would be permitted",
					"args":[
						"data_dict -> (Dictionary) input data dictionary for checking.",
						"check_config (optional) -> (bool) whether configs should be checked. Defaults to `true`",
						"check_requirements (optional) -> (bool) whether mod requirements should be checked. Defaults to `true`",
						"check_incompatibilities (optional) -> (bool) whether mod incompatibilities should be checked. Defaults to `true`",
						"config_entry_override (optional) -> (String) the entry name that is checked against the dictionary for what it uses to store config data. Defaults to 'config'",
						"mod_requirements_entry_override (optional) -> (String) the entry name that is checked against the dictionary for what it uses to store mod requirements data. Defaults to 'mod_requirements'",
						"mod_incompatibilities_entry_override (optional) -> (String) the entry name that is checked against the dictionary for what it uses to store mod incompatibility data. Defaults to 'mod_incompatibilities'"
					],
					"return":[
						"bool for whether the dictionary is valid for processing"
					]
				},
				"__config_parse":{
					"description":"Opens a config file and converts it to a dictionary",
					"args":[
						"file_path -> (String) filepath for the config file to open"
					],
					"return":[
						"Dictionary containing the config's data"
					]
				},
				"__config_store":{
					"description":"Stores a dictionary as a raw config as literally as possible",
					"args":[
						"dictionary -> (Dictionary) the data being stored",
						"file_path -> (String) filepath storing the config to"
					],
				},
			}

class DataFormat:
	const description = "Methods used to assist with the manipulation and loading of data"
	const methods = {
				"__array_to_string":{
					"description":"Converts an array into a string. Unlike String.join(), accepts any array type and will convert components to a string as best as possible.",
					"args":[
						"arr -> (Array) input array to be concatenated into a string"
					],
					"return":[
						"String containing the concatenated array"
					]
				},
				"__get_vanilla_version":{
					"description":"Fetches the game's current version. May break if any mods change the version label.",
					"return":[
						"Array containing the major, minor, and bugfix versions"
					]
				},
				"__sift_dictionary":{
					"description":"Checks a dictionary for any keys matching within an array.",
					"args":[
						"dictionary -> (Dictionary) the dictionary checked for keys",
						"search_keys -> (Array) containing all keys that are being looked for. Note that values for keys will also be checked as well"
					],
					"return":[
						"Array containing all found keys and values matching the searched keys array"
					]
				},
				"__compare_versions":{
					"description":"Compares two semantically formatted versions. Primary version must be equal or newer than the checked version to return true, otherwise returns false.",
					"args":[
						"primary_major -> (int) major version number of the primary version",
						"primary_minor -> (int) minor version number of the primary version",
						"primary_bugfix -> (int) bugfix version number of the primary version",
						"compare_major -> (int) major version number of the compared version",
						"compare_minor -> (int) minor version number of the compared version",
						"compare_bugfix -> (int) bugfix version number of the compared version",
					],
					"return":[
						"Bool that's true only when the primary version is equal or higher than the compared version"
					]
				},
				"__sift_ship_config":{
					"description":"Similar to __sift_dictionary, however assumes the dictionary is a ship config and returns the entries in a ship config-like format (i.e. cargo.equipment.SYSTEM_CARGO_MPU_BULK)",
					"args":[
						"dictionary -> (Dictionary) the ship config to sort through",
						"search_keys -> (Array) list of string entries to search for",
						"cfgs_to_ignore -> (Array) any keys within the config to remove from the search. Due to the way this works, it's highly recommended to do a deep duplication of the dictionary before searching.",
						"return_only_system_names (optional) -> (bool) whether the output array should ONLY be system names and not the entire config path. Defaults to false"
					],
					"return":[
						"Array of systems that exist within the dictionary, with the config directory attached."
					]
				},
				"__get_script_constant_map_without_load":{
					"description":"Similar to the Script.get_script_constant_map() method, however does not load the script and unlike that method is deterministic in the order of constants.",
					"args":[
						"script_path -> (String) for the file path to open"
					],
					"return":[
						"Dictionary containing each constant and it's value"
					]
				},
				"__get_script_variables_without_load":{
					"description":"Fetches the initial values of a script without loading it. NOTE: There may be issues with some variables that set their value on initialization.",
					"args":[
						"script_path -> (String) for the file path to open"
					],
					"return":[
						"Dictionary containing each variable and it's value"
					]
				},
				"__trim_scripts":{
					"description":"Opens a script and fetches information regarding variables and nodes without loading it.",
					"args":[
						"file_path -> (String) filepath of the script",
						"get_detailed_operands (optional) -> (bool) Whether any arguments and return types for methods or signals should be checked. Only use if you need it, as it slows down the process a lot. Defaults to `false`",
						"trim_unnecessary_newlines (optional) -> (bool) Whether the returned script should have any multiline variables (i.e. Arrays, Dictionaries, etc.) concatenated into a single line. Defaults to `false`",
						"recurse_through_base_scripts (optional) -> (bool) If the script extends from another script, this allows it to recurse through the extended script(s) to fetch information from those. NOTE: Scripts extended by mods do affect this. Defaults to `true`",
					],
					"return":[
						"Array containing several constituent parts for specific data types",
						" script -> (String) containing source code for the fetched script only containing variables, and constants from the script",
						" variables -> (Array) containing the names of all variables within the script",
						" constants -> (Array) containing the names of all constants within the script",
						" signals -> (Array) containing the names of all signals within the script",
						" methods -> (Array) containing the names of all methods within the script",
						" signal args -> (Array) of arrays containing the names of all arguments for the respective signal. The index of each array is respective of the index of the signal's name, and will be empty if the signal has no arguments",
						" method args -> (Array) of arrays containing the names and types for the respective method. The index of each array is respective of the index of the method's name, and will be empty if the method has no arguments. If an argument uses a specific type, will be formatted as `<arg name>: <arg type>`",
						" method return type -> (Array) of strings for the type that the method will return as. If not specified, will be blank. NOTE: If the method explicitely returns void, then it will state a void return type.",
					]
				},
				"__trim_script_object":{
					"description":"Identical to __trim_scripts, however file_path is replaced by script_source and uses a script object.",
					"args":[
						"script_source -> (Script) script object to be trimmed",
						"get_detailed_operands (optional) -> (bool) Whether any arguments and return types for methods or signals should be checked. Only use if you need it, as it slows down the process a lot. Defaults to `false`",
						"trim_unnecessary_newlines (optional) -> (bool) Whether the returned script should have any multiline variables (i.e. Arrays, Dictionaries, etc.) concatenated into a single line. Defaults to `false`",
						"recurse_through_base_scripts (optional) -> (bool) If the script extends from another script, this allows it to recurse through the extended script(s) to fetch information from those. NOTE: Scripts extended by mods do affect this. Defaults to `true`",
					],
					"return":[
						"Array containing several constituent parts for specific data types",
						" script -> (String) containing source code for the fetched script only containing variables, and constants from the script",
						" variables -> (Array) containing the names of all variables within the script",
						" constants -> (Array) containing the names of all constants within the script",
						" signals -> (Array) containing the names of all signals within the script",
						" methods -> (Array) containing the names of all methods within the script",
						" signal args -> (Array) of arrays containing the names of all arguments for the respective signal. The index of each array is respective of the index of the signal's name, and will be empty if the signal has no arguments",
						" method args -> (Array) of arrays containing the names and types for the respective method. The index of each array is respective of the index of the method's name, and will be empty if the method has no arguments. If an argument uses a specific type, will be formatted as `<arg name>: <arg type>`",
						" method return type -> (Array) of strings for the type that the method will return as. If not specified, will be blank. NOTE: If the method explicitely returns void, then it will state a void return type.",
					]
				},
				"__compile_script":{
					"description":"Compiles provided source code into a new script object",
					"args":[
						"source_code -> (String) the source code for the script"
					],
					"return":[
						"Script object using the provided source"
					]
				},
				"__compile_script_object":{
					"description":"Compiles provided source code into a new script and creates a new object from it. NOTE: This is a cached operation, and the provided object will be the same if generated from previous code unless set to use a new object.",
					"args":[
						"source_code -> (String) the source code for the script.",
						"params (optional) -> Any parameters for the object if needed by it's `_init` method. Multiple arguments can be passed by using an array. Defaults to `[]`",
						"new_object (optional) -> (bool) whether to create a new object instead of fetching the old one from the cache. Defaults to `false`",
					],
					"return":[
						"Object with the new script set as it's script"
					]
				},
				"__extend_script":{
					"description":"Extends a script from a filepath. Similar to the installScriptExtension method used in ModMain scripts",
					"args":[
						"file_path -> (String) file path for the script extension.",
					],
				},
				"__compile_and_extend_script":{
					"description":"Compiles a script and extends it. Similar to the installScriptExtension method used in ModMain scripts",
					"args":[
						"source_code -> (String) source code for the script extension.",
					],
				},
				"__extend_script_with_script_object":{
					"description":"Extends a script with a provided script object. Similar to the installScriptExtension method used in ModMain scripts.",
					"args":[
						"script -> (String) script object to extend the base script with.",
					],
				},
				"__compile_and_extend_script_with_scene":{
					"description":"Similar to __compile_and_extend_script, additionally creates and updates one or more scenes after overriding the script in case script needs to have scenes reloaded to apply the update.",
					"args":[
						"source_code -> (String) source code for the script extension.",
						"scene_path (optional) -> (String/PoolStringArray) String or PoolStringArray containing the file path or paths to scenes to be updated. Using array of paths will have them update in order. Defaults to `PoolStringArray()`"
					],
				},
				"__extend_script_with_script_object_and_scene":{
					"description":"Similar to __compile_and_extend_script_with_scene, using a script object to extend the script instead of compiling from source.",
					"args":[
						"source_code -> (String) script object to extend the base script with.",
						"scene_path (optional) -> (String/PoolStringArray) String or PoolStringArray containing the file path or paths to scenes to be updated. Using array of paths will have them update in order. Defaults to `PoolStringArray()`"
					],
				},
				"__override_script":{
					"description":"Overrides a script with another script.",
					"args":[
						"file_path -> (String) file path for the script extension.",
						"original_path -> (String) file path for the script to be overriden",
					],
				},
				"__compile_and_override_script":{
					"description":"Compiles a script and overrides the script at the provided path.",
					"args":[
						"source_code -> (String) source code for the script extension.",
						"original_path -> (String) file path for the script to be overriden",
					],
				},
				"__override_script_with_script_object":{
					"description":"Overrides a script with a provided script object.",
					"args":[
						"script -> (Script) script object to extend the base script with.",
						"original_path -> (String) file path for the script to be overriden",
					],
				},
				"__compile_and_override_script_with_scene":{
					"description":"Similar to __compile_and_override_script, additionally creates and updates one or more scenes after overriding the script in case script needs to have scenes reloaded to apply the update.",
					"args":[
						"source_code -> (String) source code for the script override.",
						"original_path -> (String) file path for the script to be overriden",
						"scene_path (optional) -> (String/PoolStringArray) String or PoolStringArray containing the file path or paths to scenes to be updated. Using array of paths will have them update in order. Defaults to `PoolStringArray()`"
					],
				},
				"__override_script_with_script_object_and_scene":{
					"description":"Similar to __compile_and_override_script_with_scene, using a script object to override the script instead of compiling from source.",
					"args":[
						"script -> (Script) script object to extend the base script with.",
						"original_path -> (String) file path for the script to be overriden",
						"scene_path (optional) -> (String/PoolStringArray) String or PoolStringArray containing the file path or paths to scenes to be updated. Using array of paths will have them update in order. Defaults to `PoolStringArray()`"
					],
				},
				"__reload_scene":{
					"description":"Recreates and updates a scene to load changed sub-resources",
					"args":[
						"scene_path -> (String) the file path to the scene to be updated.",
					],
				},
				"__replace_scene":{
					"description":"Compiles a scene, updates it's instance if an override path is provided, and returns it.",
					"args":[
						"scene_data -> (String) data for the scene stored as a string. This must be a valid scene structure for this operation to work.",
						"override_path (optional) -> (String) if provided, the file path to update a pre-existing scene with. Scene must be visible to the engine to be replaced. Defaults to ''",
						"scene_file_path (optional) -> (String) if set, defines a specific path to save the scene to. If left blank, instead stores it in the Variable_Fetch cache with a random name. Defaults to ''",
						"cache_scene (optional) -> (bool) whether to cache the file to prevent it from being garbage collected. Caching automatically happens if updating a file at override_path. Defaults to true."
					],
					"return":[
						"If the scene data was valid, a PackedScene as the compiled scene, otherwise null."
					]
				},
				"__replace_resource":{
					"description":"Sets the path for a resource to a specific path, equivalent to the replaceScene methods from modmains.",
					"args":[
						"resource_path -> (String) the file path of the scene or resource to be used to update the resource.",
						"original_path -> (String) the original file path of the scene to be updated.",
					],
				},
				"__convert_var_from_string":{
					"description":"Converts a string containing a variable in the literal sense (as if it were written in a script) into it's variant form. NOTE: Strings need to have their quotes inside the string quotes to be considered valid. E.g. `\"\"this is a string\"\"`, \"Vector2(1,2)\"",
					"args":[
						"string -> (String) the variable written in the literal sense as a string",
						"constant (optional) -> Whether the variable should use a constant or variant definition for it. Setting this to false can be useful if the desired output cannot be stored as a constant when in a script. Defaults to `true`",
					],
					"return":[
						"Variant from the literal conversion"
					]
				},
				"__load_if_can":{
					"description":"Loads a resource at the provided filepath and stores it, acting as a boolean to check if it exists or not. Stored objects will be initialized as null, and if the output of this method would be null, will be reflected by the last load.",
					"args":[
						"filepath -> (String) the file path to the desired resource to load",
						"override_cache (optional) -> (bool) whether to load the resource anew, ignoring the cache. Equivalent to the similar property for ResourceLoader.load(). NOTE: Setting this true can be problematic with extended scripts. Defaults to false",
						"type_hint (optional) -> (String) whether to define a specific resource type that this object has to be. Equivalent to the similar property for ResourceLoader.load(). Defaults to \"\"",
					],
					"return":[
						"Bool for whether the object was loaded or not."
					]
				},
				"__get_load":{
					"description":"Fetches the last object loaded by __load_if_can. Note that if the load failed or if the object is invalid, it will null the object, so make sure to use that method to confirm a load before trying to fetch the object.",
					"args":[
						"get_last_successful (optional) -> (bool) whether to get the last successfully loaded object by __load_if_can. Since this initializes as null, __load_if_can needs to have been successful at least once. Defaults to false",
					],
					"return":[
						"Bool for whether the object was loaded or not."
					]
				},
				"__is_valid_url":{
					"description":"Checks a provided URL to see if it's valid.",
					"args":[
						"URL -> (String) the URL to be checked",
					],
					"return":[
						"Bool for whether the URL is valid."
					]
				},
				"__loadDLC":{
					"description":"Clears cache as a fix for issues with loading DLC."
				},
				"__split_array_by_length":{
					"description":"splits a provided array (or array of any Pool type) into an array containing arrays of the input's type by the splitting ammount. Also lets you return one of these specific sections instead.",
					"args":[
						"arr -> (Array/PoolArray) input array for ",
						"length -> (int) the size of each section to be split into. If the array does not split evenly by this ammount, the last array will be the remainder",
						"specific_section (optional) -> (int) the index of the specific section to be fetched. If this value is out of bounds of the indeces of the usual output array, it will return an empty array. This can be useful to get specific parts of a very large array without needing to hang the game trying to fetch all at once. Defaults to `-1`",
					],
					"return":[
						"Array containing the arrays/pools for each section split by length",
						"If specific_section is set and in bounds of the usual output, will instead return the corresponding array/pool."
					]
				},
				"__stringify_property":{
					"description":"Converts a property into a string literal that can be used inside a script file.",
					"args":[
						"property -> (Variant) the property to be converted into a string literal.",
						"depth (optional) -> (int) for any array-like or dictionary properties, the base tab depth for the properties. If not doing anything clever, best leaving at default. Defaults to '0'.",
						"stringify (optional) -> (bool) whether the output should be encased in double quotes and ready to be inserted into a script file. Should only be disabled if the returned string is being added to another output. Defaults to 'true'.",
					],
					"return":[
						"String containing the property as could be inserted into a script file. Will still need property identifiers (var, const, etc.)"
					]
				},
				"__reserve_in_array":{
					"description":"A safer resize method for arrays that works on a relative size change, and initializes blank spaces with a blanked/zeroed value (or null for regular arrays). Can also reduce size safely and ensures the size never goes below zero. Returns null if inputting any non-array property.",
					"args":[
						"array -> (ANY Array/PoolArray) the array to be resized. Returns null if not an array constructor.",
						"count -> (int) the size to change the array by. Can be negative to reduce the size by X indeces.",
						"absolute (optional) -> (bool) whether count acts as the absolute size instead of the relative size change."
					],
					"return":[
						"Array/PoolArray of the respective input type with the readjusted size.",
						"null if `array` was not an array constructor."
					]
				},
				"__to_uint32":{
					"description":"Converts an integer into an unsigned 32 bit integer",
					"args":[
						"integer -> (int) the input integer"
					],
					"return":[
						"int for the unsigned 32 bit value"
					]
				},
				"__get_crc_32":{
					"description":"Calculates the 32-bit CRC checksum from a set of bytes",
					"args":[
						"bytes -> (PoolByteArray) bytes to generate the checksum from"
					],
					"return":[
						"int for the 32 bit checksum"
					]
				},
				"__get_uint32_from_buffer":{
					"description":"Fetches the next 32 bits from a PoolByteArray and provides it as an unsigned 32 bit int",
					"args":[
						"buffer -> (PoolByteArray) bytes to fetch the integer from",
						"offset (optional) -> (int) the position to offset the bytes to fetch. Defaults to 0"
					],
					"return":[
						"int for the unsigned 32 bit value"
					]
				},
				"__get_uint16_from_buffer":{
					"description":"Fetches the next 16 bits from a PoolByteArray and provides it as an unsigned 16 bit int",
					"args":[
						"buffer -> (PoolByteArray) bytes to fetch the integer from",
						"offset (optional) -> (int) the position to offset the bytes to fetch. Defaults to 0"
					],
					"return":[
						"int for the unsigned 16 bit value"
					]
				},
				"__decompress_raw_deflate_stream":{
					"description":"Decompresses a DEFLATE data stream without the header or uint32 Adler. PoolByteArray.decompress() requires the proper headers, which can't be created without knowing the decompressed data.",
					"args":[
						"buffer -> (PoolByteArray) bytes that form the DEFLATE stream",
						"max_size (optional) -> (int) if above zero, the maximum size for the output data. Use for potentially untrustworthy data. Defaults to 0"
					],
					"return":[
						"PoolByteArray for the raw, uncompressed data"
					]
				},
				"__compress_to_raw_deflate_stream":{
					"description":"Compresses a PoolByteArray to form a DEFLATE data stream without the header or uint32 Adler",
					"args":[
						"buffer -> (PoolByteArray) bytes for the raw, uncompressed data."
					],
					"return":[
						"PoolByteArray that form the DEFLATE stream"
					]
				},
			}

class DriverManagement:
	const description = "Contains methods used to fetch driver information from mods"
	const methods = {
				"__get_drivers":{
					"description":"Fetches driver data from the filesystem",
					"args":[
						"get_ids (optional) -> (Array) mod IDs to fetch specific drivers from. If left empty, fetches all drivers. Defaults to `[]`"
					],
					"return":[
						"Array of dictionaries for each mod's drivers, with each dictionary being formatted as such:",
						" drivers -> dictionary containing all drivers for the specific mod, with each entry formatted as such: {<driver name (String, e.g. ADD_EQUIPMENT_ITEMS.gd)>:<driver contents (Dictionary)>}",
						" id -> (String) ID of this mod. Not present if the mod doesn't have an ID.",
						" priority -> (int) mod's priority. Will be zero if not defined in the mod main.",
						" mod_directory -> (String) the path to the mod's directory, or where the ModMain.gd file exists in",
					]
				},
				"__get_drivers_from_modmain_path":{
					"description":"Fetches drivers from a ModMain.gd filepath",
					"args":[
						"file_path -> (String) the filepath to the ModMain.gd file",
						"get_fresh_drivers (optional) -> (bool) since drivers are cached, whether the cache should be renewed and refetch drivers. Defaults to `false`"
					],
					"return":[
						"Dictionary with each driver script name as a key, with a dictionary containing it's constant map as the respective value."
					]
				},
				"__is_driver_file":{
					"description":"Checks a provided filepath to see if it's a driver file or not",
					"args":[
						"file_path -> (String) the filepath to check. Does not need to exist, rather just if it could be a valid driver."
					],
					"return":[
						"bool for whether the filepath is a valid driver or not"
					]
				}
			}

class Equipment:
	const description = "Contains internal methods used for creating equipment scenes. Use at your own discretion"
	const methods = {
				"__make_upgrades_scene":{
					"description":"Internal method that initializes and creates multiple scene and script handles, as well as data caches, all used by equipment-adjacent processes.",
				},
				"__make_equipment_for_scene":{
					"description":"Internal method for creating a scene string for an equipment item to be added to an Upgrades.tscn scene package.",
					"args":[
						"equipment_data -> (Dictionary) the dictionary containing equipment item data",
						"slot_node_name -> (String) the node name for the slot the equipment is being added to",
						"system_slot -> (String) the ship slot the equipment is being added to"
					],
					"return":[
						"String containing a full equipment item"
					]
				},
				"__make_slot_for_scene":{
					"description":"Internal method for creating a scene string for a slot to be added to an Upgrades.tscn scene package.",
					"args":[
						"slot_data -> (Dictionary) dictionary containing slot data"
					],
					"return":[
						"Array containing a full slot item"
					]
				},
			}

class Events:
	const description = "Contains methods to help spawn or clear events in the ring"
	const methods = {
				"__spawn_event":{
					"description":"Spawns an event in the rings",
					"args":[
						"event -> (String) the event name to be spawned",
						"ring -> TheRing node. Must be present to work.",
						"parameters (optional) -> (Dictionary) Any parameters used for spawning events. Defaults to `{}`. Currently supports:",
						"	legacy -> (bool) whether it should use a very old hacky method of hijacking the testSpecificStoryElement property to spawn the event. Has to wait at least 0.1 seconds inbetween spawns. Defaults to `false`",
						"	inject -> (bool) whether the event should be placed directly in the ring, bypassing any event handling methods. Has issues with POI-based events. Defaults to `false`",
#						"	x_direction -> (float) horizontal direction which the event will be spawned in. Will be clamped if it exceeds -1 or 1. Defaults to a random range between -1 and 1.",
#						"	y_direction -> (float) vertical direction which the event will be spawned in. Will be clamped if it exceeds -1 or 1. Defaults to a random range between -1 and 1.",
#						"	spawn_direction_scale -> (float) how much your ship's velocity will be scaled by when calculating the offset added by your velocity. Defaults to 0.75",
#						"	oddity_spawn_radius_min -> (int) minimum distance the event will spawn under normal conditions. NOTE: 1 unit represents 100 cm. Defaults to 24000",
#						"	oddity_spawn_radius_min_cutscene -> (int) minimum distance the event will spawn while in a cutscene (which only happens during astrogation in the vanilla game to make POI events close to the ship when travelling). NOTE: 1 unit represents 100 cm. Defaults to 6000",
#						"	oddity_spawn_radius_max -> (int) maximum distance the event is allowed to spawn at under normal conditions",
						"delay_seconds (optional) -> (float) if set above zero, the number of seconds before the event is spawned",
					],
				},
				"__clear_event":{
					"description":"Clears all objects related to a defined event from the ring",
					"args":[
						"event -> (String) the event name to be removed",
						"ring -> TheRing node. Must be present to work.",
						"clear_related_poi -> (bool) Whether any POI with the same event name near deleted objects should be deleted as well. Defaults to `true`",
						"clear_in_cargo -> (bool) Whether to remove any event-related oddities considered inside the cargo bay of or attached to other ships. Defaults to `false`"
					],
				},
			}

class FileAccess:
	const description = "Methods to aide with file interactions"
	const methods = {
				"__get_file_content":{
					"description":"Method that simplifies the usual process of File.get_as_text()",
					"args":[
						"file_path -> (String) the file path to be read"
					],
					"return":[
						"String with the contents of the file"
					]
				},
				"__copy_file":{
					"description":"Copies a file to a folder, overriding files without warning. Automatically handles conversion of file path formatting.",
					"args":[
						"file_path -> (String) the path to the file to be copied",
						"folder -> (String) the directory to copy the file to",
					],
					"return":[
						"Error code for the copy operation"
					]
				},
				"__load_png":{
					"description":"Reads and parses a PNG file during runtime, without the need to precompile to STEX. Also supports JPG/JPEG, BMP, and WEBP formats.",
					"args":[
						"filepath -> (String) the file path to the PNG file",
						"fallback (optional) -> (Image) an image resource to use as a fallback if the image file provided by filepath fails to load."
					],
					"return":[
						"ImageTexture containing the image."
					]
				},
				"__precache_mod_file":{
					"description":"Prepares a file to be copied to the mod folder. This will mark the game for needing a restart, which Mod Menu 2 will start requesting upon opening it.",
					"args":[
						"filepath -> (String) the file path to the mod."
					],
				},
				"__load_precached_mods":{
					"description":"Copies any prepared mods to the mod folder, and reboots if there are mods to copy. Normally this is done on game boot to provide a reliable experience for players. NOTE: Rebooting will happen at all cases with mods existing, even if it's safe to copy. Double check 'user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt', which will have a `1` stored if there are mods to copy, and `0` otherwise.",
				},
				"__save_stex(image:Image, file_path:String, flags:int=0)":{
					"description":"Saves a provided image resource as a .stex file",
					"args":[
						"image -> (Image) the image data to be saved.",
						"file_path -> (String) the file path to save the .stex file to. Note that this always changes the extension to .stex",
						"flags (optional) -> (int) the texture flags for the image. Check the Texture.Flags enum for reference."
					]
				},
				"__get_uid_of_file":{
					"description":"Returns a unique identifier string for the provided file.",
					"args":[
						"file_path -> (String) file path to check."
					],
					"return":[
						"String for the file uid. Will be an empty string if the file does not exist."
					]
				},
				"__file_output_to_buffer":{
					"description":"Ensures a file input is a PoolByteArray.",
					"args":[
						"content -> (String/PoolByteArray) file content. Can be either a string or PoolByteArray"
					],
					"return":[
						"PoolByteArray for the output buffer."
					]
				},
				"__file_exists":{
					"description":"An all-encompassing method to determine if a file exists in the filesystem, without the need to query File and ResourceLoader directly",
					"args":[
						"file_path -> (String) the file path to the desired resource to check. Can be both relative, global, or OS-global",
					],
					"return":[
						"Bool for whether the file at file_path exists or not."
					]
				},
				"__get_real_filename_from_compiled_resource":{
					"description":"If the provided filepath would match a compiled resource (extension is .gdc or .converted.res), matches an appropriate filepath where the actual resource exists for it.",
					"args":[
						"file_path -> (String) Filepath for the file to check"
					],
					"return":[
						"Actual resource path for the file. Returns the provided filepath if it doesn't match."
					]
				},
				"__get_dependancies_for_file":{
					"description":"Fetches all resource dependancies for the provided filepath, including compiled .res and .gdc files found within the .pck file. Can optionally perform a deep check for res:// filepaths not exposed by ResourceLoader.",
					"args":[
						"file_path -> (String) the resource's filepath to check.",
						"deep_search (optional) -> (bool) whether to perform a deep search for all res:// file paths within the resource. Defaults to false"
					],
					"return":[
						"PoolStringArray containing all dependancy file paths."
					]
				}
			}

class FolderAccess:
	const description = "Methods used to help with directory management"
	const methods = {
				"__check_folder_exists":{
					"description":"Checks whether a directory exists, and creates it if it doesn't.",
					"args":[
						"folder -> (String) the path to the directory",
						"status_array -> (bool) Whether the output value should be an array containing more verbose information. Defaults to `false`"
					],
					"return":[
						"Bool for whether the directory exists after running this method",
						"If status_array is true, instead returns an array containing two values. First value is whether the directory exists after running the method, and the second is whether it existed before running the method."
					]
				},
				"__recursive_delete":{
					"description":"Removes a folder and all of it's contents if it's not empty.",
					"args":[
						"path -> (String) path to the folder to be deleted"
					],
					"return":[
						"Bool whether the base directory could be accessed."
					]
				},
				"__fetch_folder_files":{
					"description":"Fetches a folder's contents",
					"args":[
						"folder -> (String) path to the directory to fetch the contents of",
						"show_folders (optional) -> (bool) Whether to display any subdirectories, which will have a forward slash at the end of the name to differentiate them. Defaults to `false`",
						"return_full_path (optional) -> (bool) Whether to show the full directory path of the file/folder, instead of just the name. Defaults to `false`",
						"globalize_path (optional) -> (bool) Whether to globalize the path with ProjectSettings.globalize_path() Defaults to `false`",
						"recursive_search (optional) -> (bool) whether files would be searched from within subdirectories. Folder paths still respect `show_folders`, and file paths will be relative to the base directory if `return_full_path` is false",
					],
					"return":[
						"Array containing strings for the names of all files and/or folders within the provided directory."
					]
				},
				"__get_first_file":{
					"description":"Fetches the first file within a directory.",
					"args":[
						"folder -> (String) the path to the directory"
					],
					"return":[
						"String for the first file. If no files exist, string will be empty."
					]
				},
				"__get_folder_structure":{
					"description":"Fetches the folder structure of a given directory as a dictionary.",
					"args":[
						"folder -> (String)",
						"store_file_content (optional) -> (bool) Whether to store the file content as the value of a file's entry instead of just 'FILE'. Defaults to `false`",
						"recache (optional) -> (bool) whether the directory cache should be re-fetched. Defaults to true"
					],
					"return":[
						"Dictionary containing the entire directory's structure"
					]
				},
				"__get_files_with_extensions":{
					"description":"Fetches all files within the provided subfolder with an extension that matches one of the contents of the extensions PoolStringArray",
					"args":[
						"folder -> (String) directory path to fetch the files from.",
						"extensions -> (PoolStringArray) extensions to skip. Must not include the period prefix.",
						"recurse_depth (optional) -> (int) how far this operation will search into subfolders. -1 will search indefinitely, and 0 will stick to the provided directory only."
					],
					"return":[
						"Array containing all valid file paths that match the extensions criteria."
					]
				},
				"__get_vanilla_script_and_scenes":{
					"description":"Fetches all vanilla scripts and scenes from the PCK file. NOTE: editor builds MUST keep GDRE's .autoconverted directory since no PCK file is readily available to source data from. To get PCK data in-editor, use Zip.__load_pck.",
					"return":[
						"PoolStringArray containing all valid scripts and scenes"
					]
				},
			}

class Github:
	const description = ""
	const methods = {
		
	}

class HevLib:
	const description = ""
	const methods = {
		
	}

class Keymapping:
	const description = ""
	const methods = {
		
	}

class ManifestV1:
	const description = ""
	const methods = {
		
	}

class ManifestV2:
	const description = ""
	const methods = {
		"__mod_exists":{
			"description":"Checks if a mod exists based on mod ID, with optional version check parameters.",
			"args":[
				"check_data -> (Variant) the data used to check if the mod exists. See the following lines for acceptable inputs:",
				" -> (String) mod ID for the mod to check for. Performs no version checking, and will return purely if a mod with the ID exists.",
				" -> (Array) assumes it contains multiple entries to check. If any one of these entries exist, the entire check passes",
				" -> (Dictionary) must contain `mod_id` for the mod ID, and can have either minimum_version or min_version represent the minimum version, and either maximum_version or max_version represent the maximum version.",
				"   -> min/max version entries can either be an Array/PoolIntArray with 3 indeces for the major, minor, and bugfix versions, a Vector3 with the versions in each respective index, or a dictionary with `major`, `minor`, and `bugfix` keys containing each respective version.",
			],
			"return":[
				"bool for whether the mod exists based on the provided criteria"
			]
		},
	}

class Math:
	const description = ""
	const methods = {
		"__rotate_point":{
			"description":"Provides a Vector2 point after being rotated around (0,0)",
			"args":[
				"point -> (Vector2) point that is being rotated around (0,0)",
				"angle -> (float) angles to rotate by",
				"degrees (optional) -> (bool) for whether 'angle' should be treated as degree angles, and uses radians if not. Defaults to `true`"
			],
			"return":[
				"Vector2 for the rotated point"
			]
		},
		"__factorial":{
			"description":"Calculates the factorial of the provided integer",
			"args":[
				"n -> (int) the number to be set to it's factorial"
			],
			"return":[
				"int for the output factorial"
			]
		},
		"__get_unique_pairs":{
			"description":"Provides an array of PoolIntArrays of all pairs of numbers in a range from zero to the provided integer (not inclusive). E.g. 3 = [[0,1],[0,2],[1,2]]",
			"args":[
				"max_value -> (int) the range of the pairs, non-inclusive"
			],
			"return":[
				"Array of PoolIntArrays for each pair."
			]
		},
		"__convert_arr_to_vec2arr":{
			"description":"Converts an array containing integers and/or floats into a PoolVector2Array",
			"args":[
				"array -> (Array) for the data being converted into a PoolVector2Arr."
			],
			"return":[
				"PoolVector2Array for the output variables.",
				"NOTE: If the input array has an odd length, or contains any variables that are not of int/float type, the returning PoolVector2Array will be empty."
			]
		},
		"":{
			"description":"",
			"args":[
				
			],
			"return":[
				
			]
		},
	}

class NodeAccess:
	const description = ""
	const methods = {
		
	}

class RingInfo:
	const description = ""
	const methods = {
		
	}

class SafeMode:
	const description = ""
	const methods = {
		
	}

class TimeAccess:
	const description = ""
	const methods = {
		"__get_dos_datetime":{
			"description":"Converts a datetime dictionary into a dictionary containing DOS date and time values",
			"args":[
				"datetime (optional) -> (Dictionary) a date time dictionary. Defaults to Time.get_datetime_dict_from_system() for the current local timestamp."
			],
			"return":[
				"Dictionary containing a 'time' and 'date' key/value pair."
			]
		},
	}

class Translations:
	const description = ""
	const methods = {
		
	}

class WebTranslate:
	const description = ""
	const methods = {
		
	}

class Zip:
	const description = ""
	const methods = {
		
	}
