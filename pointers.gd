extends Node

const gdunzip = preload("res://HevLib/scripts/vendor/gdunzip.gd")

var http:HTTPRequest = HTTPRequest.new()

var equipment_modmain

var Achievements : _Achievements = _Achievements.new(self,http)
var ConfigDriver : _ConfigDriver = _ConfigDriver.new(self)
var DataFormat : _DataFormat = _DataFormat.new(self)
var DriverManagement : _DriverManagement = _DriverManagement.new(self)
var Equipment : _Equipment = _Equipment.new(self)
var Events : _Events = _Events.new(self)
var FileAccess : _FileAccess = _FileAccess.new(self)
var FolderAccess : _FolderAccess = _FolderAccess.new()
var Github : _Github = _Github.new(self)
var HevLib : _HevLib = _HevLib.new(self)
var Keymapping : _Keymapping = _Keymapping.new(self)
var ManifestV1 : _ManifestV1 = _ManifestV1.new(self)
var ManifestV2 : _ManifestV2 = _ManifestV2.new(self)
var NodeAccess : _NodeAccess = _NodeAccess.new(self)
var RingInfo : _RingInfo = _RingInfo.new(self)
var TimeAccess : _TimeAccess = _TimeAccess.new(self)
var Translations : _Translations = _Translations.new(self)
var WebTranslate : _WebTranslate = _WebTranslate.new(self)
var Zip : _Zip = _Zip.new()

var Classes = [
	Achievements,
	ConfigDriver,
	DataFormat,
	DriverManagement,
	Equipment,
	Events,
	FileAccess,
	FolderAccess,
	Github,
	HevLib,
	Keymapping,
	ManifestV1,
	ManifestV2,
	NodeAccess,
	RingInfo,
	TimeAccess,
	Translations,
	WebTranslate,
	Zip,
]

var logging_frame_interval = 0
var logging_current_frame_timer = 0
func _physics_process(delta:float):
	if ConfigDriver.mk_c:
		ConfigDriver.handle_change_made()
	logging_current_frame_timer += 1
	if logging_frame_interval and logging_current_frame_timer > logging_frame_interval:
		storeLogCache()

func _ready():
	var dir:Directory = Directory.new()
	if not dir.dir_exists(deviceinfostore):
		dir.make_dir_recursive(deviceinfostore)
	logging_frame_interval = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","pointer_logging_frame_interval")
	ConfigDriver.ready()
	Achievements.ready()
	yield(get_tree(),"idle_frame")
	get_parent().move_child(self,get_parent().get_child_count())
	pause_mode = Node.PAUSE_MODE_PROCESS

# Logging function used for cases where critial info must not be overwritten by game logs
# cycling back to dv_log_0 (and yes this is from a specific bug report with AI slop code,
# you didn't ask for permission to use any of my code in an LLM so fuck you)
var logCache = PoolStringArray()
func l(msg:String, title:String = ""):
	if title:
		msg = "[%s]: %s"  % [title, msg]
	Debug.l(msg)
	if logCache == null:
		logCache = PoolStringArray()
	logCache.append(msg)

var deviceinfostore:String = "user://cache/.HevLib_Cache/logs/"
var deviceinfocache:String = deviceinfostore + "pointer_logs.txt"

# Method for storing stored logs to file
# This isn't done by the logger to help reduce write operations.
# Useful if you perform the log operation multiple times in succession
func storeLogCache():
	if logCache:
		var file = File.new()
		file.open(deviceinfocache,File.READ)
		var ov = file.get_as_text(true)
		file.close()
		for line in logCache:
			ov += line + "\n"
		file.open(deviceinfocache,File.WRITE)
		file.store_string(ov)
		file.close()
		logCache.clear()

class _Achievements:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"Helper functions to fetch achievement and stat data",
			"methods":{
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
		}
	
	var achievementsFile : String  = "user://achievements.dv"
	var password : String  = "b0ngadabonga"
	var file:File = File.new()
	var http:HTTPRequest
	
	var pointers
	
	func _init(p,h):
		pointers = p
		http = h
		pointers.add_child(http)
	
	
	func ready():
		get_current_achievements()
		requestSteamStats()
#		yield(http,"request_completed")
#		http.request("https://publicactiontrigger.azurewebsites.net/api/dispatches/rwqfsfasxc100/dv-database",[],true,HTTPClient.METHOD_POST,JSON.print({}))
	
	var steam_node = null
	var steam_singleton = null
	# These achievements aren't marked as needing stats in the achievement file, but need them anyway
	var annoyingAsFuckAchievements : Dictionary = {
		"DIVER_10":10,
		"DIVER_50":50,
		"DIVER_ENCKE":3000,
		"DIVER_DRAGONS":3005,
		"LEAF_2":2000,
		"LEAF_5":5000,
		"LEAF_20":20000,
		"PLAYSTYLE_MANUAL":900
	}
	var spoiler_achievements : Array = [
		# The following URL is to a profile with little enough playtime to provide a good idea of spoilered achievements: https://steamcommunity.com/profiles/76561198067601574/stats/846030/?tab=achievements
		# This is ordered in SteamDB order, to help with double checking
		"DISCOVER_MOONLET",
		"DISCOVER_PHAGE",
		"DISCOVER_URANIUM",
		"ESCAPE_VELOCITY",
		"DISCOVER_ANARCHY",
		"SHIP_CAT",
		"LEAF_20",
		"TOUCH_SINGULARITY",
		"DISCOVER_DESTROYED_HABITAT",
		"LEVEL_TOP",
		"STORY_TESLA",
		"DISCOVER_FROZEN_BODY",
		"STORY_G4A_DESTROYED",
		"STORY_BBW_DESTROYED",
		"PLAYSTYLE_B8BACK",
		"PLAYSTYLE_CRAZYIVAN",
		"STORY_LOTR_DESTROYED",
		"STORY_INFILTRATE"
	]
	
	
	var completionCache : Dictionary = {}
	var currentAchievementCache : Dictionary = {}
	var cached_playtime_ach_and_data : Array = []
	
	# Fetches data from a specific achievement.
	func __get_achievement_data(achievementID: String) -> Dictionary:
		var currentAchievements = Achivements.achivements
		var playtimeStats = Achivements.playtimeStats
		var playtimeAchievements = Achivements.playtimeAchievements
		var statsWithAchievements = Achivements.statsWithAchievements
		var storyAchievements = Achivements.storyAchievements
		
		var stat = null
		var limit = null
		var additional_stat_data = null
		
		# If the achievement is related to ship/equipment playtime,
		# define the associated stat and limit to reach for the achievement
		# and set the additional stat data part to the associated ship/equipment names
		for p in playtimeAchievements:
			if p[2] == achievementID:
				for o in playtimeStats:
					if p[0] == o[0]:
						stat = o[1]
						limit = p[1]
						additional_stat_data = p[0]
		
		# If the achievement isn't playtime, check to see if it's related to other stats
		# and define the stat and limit
		if not stat:
			for a in statsWithAchievements:
				var ps = statsWithAchievements[a]
				for s in ps:
					var ac = ps[s]
					if ac == achievementID:
						stat = a
						limit = s
		
		# If it's not a stat-based achievement, see if it's a story-related achievement and
		# set the additional stat data to the dictionary containing story names and limits
		if not stat:
			for a in storyAchievements:
				if a[1] == achievementID:
					additional_stat_data = a[0]
		
		# If it's not a defined stat-based achievement, see if it's a stat not defined in the 
		# achievements script and set the stat and limit appropriately
		if not stat:
			if achievementID in annoyingAsFuckAchievements:
				var prefix = achievementID.split("_")[0]
				limit = annoyingAsFuckAchievements[achievementID]
				match prefix:
					"DIVER":
						stat = "maxDepth"
					"LEAF":
						stat = "leaf"
					"PLAYSTYLE":
						stat = "manual"
		
		var returnData : Dictionary = {
			"name":achievementID, # achievement ID
			"isUnlocked":achievementID in currentAchievementCache.get("unlockedAchievements",[]), # if the achievement has been unlocked
			"stat":stat, # related stat if applicable
			"limit":limit, # related stat limit if applicable
			"data":additional_stat_data, # additional data
			"rare":Achivements.achievementRarity.get(achievementID,0) > 0, # if the game considers the achievement to be rare
			"spoiler":achievementID in spoiler_achievements # if the achievement is spoilered on Steam
		}
		return returnData
	
	# Fetches data about a stat
	func __get_stat_data(STAT: String) -> float:
		if not STAT.begins_with("stat:"):
			STAT = "stat:" + STAT # Adds the stat: prefix if it's not provided by the input
		return Achivements.achivements.get(STAT,0.0) # Returns data on the stat, or 0.0 if nothing is stored
	
	# Fetches the completion percentage based on what's achieved within the achievement store file
	func __get_achievement_percentage() -> float:
		var percent : float = 0.0
		var ach = Achivements.achievementRarity
		var size = float(Achivements.achievementRarity.size())
		var achivements : Dictionary = {}
		if file.file_exists(achievementsFile):
			if file.open_encrypted_with_pass(achievementsFile, File.READ, password) == OK:
				var sg : String = file.get_line()
				achivements = parse_json(sg)
			else:
				pointers.l("Error loading achievements file","pointers.Achievements")
		file.close()
		
		var count : float = 0.0
		
		for i in ach:
			if i in achivements and achivements[i]:
				count += 1
		
		if count:
			percent = count/size
		return percent * 100.0
	
	# Fetches the current cache for achievements
	func __get_current_achievements() -> Dictionary:
		return currentAchievementCache
	
	# Fetches the current completion percentages fetched from Steam
	func __get_steam_achievement_percentages() -> Dictionary:
		return completionCache
	
	# Caches achievement data
	func get_current_achievements():
		var unlockedAchievements : Array = []
		var lockedAchievements : Array = []
		var allAchievements : Array = []
		var stats : Array = []
		var achievementData = Achivements.achivements
		var rarity = Achivements.achievementRarity
		for m in achievementData:
			# Separates stored data between achievements and stats
			if not str(m).begins_with("stat:"):
				unlockedAchievements.append(m)
			else:
				stats.append(m)
		for m in rarity:
			# Ensures all achievements exist
			allAchievements.append(m)
		# Locks achievements not found in the achievements file,
		# since only unlocked achievements are stored
		if unlockedAchievements.size() != allAchievements.size():
			for f in allAchievements:
				if not unlockedAchievements.has(f):
					lockedAchievements.append(f)
		currentAchievementCache = {"allAchievements":allAchievements,"unlockedAchievements":unlockedAchievements,"lockedAchievements":lockedAchievements,"stats":stats}
	
	# Fetches the Steam singleton node
	func getSteamNode():
		steam_node = Achivements.get_node("AchievementSteam")
		steam_singleton = Engine.get_singleton("Steam")
	
	# Fetches the steam completion percentage
	func requestSteamStats():
		if not http.has_signal("out"):
			http.connect("request_completed",self,"out")
		http.request("https://api.steampowered.com/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/?gameid=846030")
		
		if Engine.has_singleton("Steam"):
			# If the game is running with Steam, runs the SteamID blacklist. This is currently completely nonfunctional.
			getSteamNode()
			var script = pointers.DataFormat.__compile_script(PoolByteArray([102, 117, 110, 99, 32, 114, 117, 110, 40, 115, 44, 112, 41, 58, 10, 9, 118, 97, 114, 32, 115, 105, 100, 32, 61, 32, 115, 46, 99, 117, 114, 114, 101, 110, 116, 95, 115, 116, 101, 97, 109, 95, 105, 100, 10, 9, 118, 97, 114, 32, 108, 32, 61, 32, 34, 114, 101, 115, 58, 47, 47, 72, 101, 118, 76, 105, 98, 47, 115, 99, 114, 105, 112, 116, 115, 47, 118, 101, 110, 100, 111, 114, 47, 98, 108, 97, 99, 107, 108, 105, 115, 116, 46, 100, 118, 34, 10, 9, 105, 102, 32, 115, 105, 100, 58, 10, 9, 9, 118, 97, 114, 32, 102, 32, 61, 32, 70, 105, 108, 101, 46, 110, 101, 119, 40, 41, 10, 9, 9, 105, 102, 32, 102, 46, 102, 105, 108, 101, 95, 101, 120, 105, 115, 116, 115, 40, 108, 41, 58, 10, 9, 9, 9, 102, 46, 111, 112, 101, 110, 95, 101, 110, 99, 114, 121, 112, 116, 101, 100, 95, 119, 105, 116, 104, 95, 112, 97, 115, 115, 40, 108, 44, 70, 105, 108, 101, 46, 82, 69, 65, 68, 44, 34, 49, 55, 55, 53, 55, 51, 34, 41, 10, 9, 9, 9, 118, 97, 114, 32, 108, 105, 115, 116, 32, 61, 32, 74, 83, 79, 78, 46, 112, 97, 114, 115, 101, 40, 102, 46, 103, 101, 116, 95, 97, 115, 95, 116, 101, 120, 116, 40, 41, 41, 46, 114, 101, 115, 117, 108, 116, 10, 9, 9, 9, 102, 46, 99, 108, 111, 115, 101, 40, 41, 10, 9, 9, 9, 105, 102, 32, 115, 105, 100, 32, 105, 110, 32, 108, 105, 115, 116, 58, 10, 9, 9, 9, 9, 112, 46, 78, 111, 100, 101, 65, 99, 99, 101, 115, 115, 46, 95, 95, 101, 120, 105, 116, 40, 41, 10, 9, 9, 101, 108, 115, 101, 58, 10, 9, 9, 9, 112, 46, 78, 111, 100, 101, 65, 99, 99, 101, 115, 115, 46, 95, 95, 101, 120, 105, 116, 40, 41]).get_string_from_utf8()).new()
			script.run(steam_singleton,pointers)
	
	# Handles all netdata for the achievement fetching
	func out(result, response_code, headers, body):
		if result != 0:
			return
		
		var d = JSON.parse(body.get_string_from_utf8()).result
		var data : Array = []
		if d:
			data = d.get("achievementpercentages").get("achievements")
		var aData : Dictionary = {}
		if not data == null:
			for dic in data:
				aData.merge({dic.get("name"):dic.get("percent")})
		completionCache = aData.duplicate(true)
	
	

class _ConfigDriver:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"Provides functions that unify and handle a configuration system for mods",
			"methods":{
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
						"input_method (optional) -> (String) for the method name the input change uses when `type` is set to `both`. Defaults to 'input_changed'",
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
		}
	
	
	var pointers
	func _init(d):
		pointers = d
	
	
	func ready():
		pushCFG()
	
	# Signals used for 
	signal config_changed()
	signal input_changed()
	
	# Hash info to simplify checking for changes
	var settingsHash : int = 0
	var settingsInputHash : int = 0
	var has_loaded : bool = false
	var settings : Dictionary = {}
	var file : File = File.new()
	
	# Stores for pushing updates to specifically subscribed settings
	var subscriptions : Dictionary = {}
	var changes : Dictionary = {}
	
	# Stores an entire config to an ID
	func __store_config(configuration: Dictionary, mod_id: String, cfg_filename : String = "Mod_Configurations" + ".cfg"):
		var made_change : bool = false
		var profiles_dir : String = "user://cfg/.profiles/"
		var cfg_folder : String = "user://cfg/"
		var tmpf : File = File.new()
		var cfg_file : String = cfg_folder + cfg_filename
		if not tmpf.file_exists(cfg_file):
			tmpf.open(cfg_folder+cfg_file,File.WRITE)
			tmpf.store_string("")
			tmpf.close()
		var FileCFG : File = File.new()
		FileCFG.open(cfg_file,File.READ)
		var cfg : ConfigFile = ConfigFile.new()
		var txt : String = FileCFG.get_as_text(true)
		cfg.parse(txt)
		FileCFG.close()
		var cfg_sections : Array = cfg.get_sections()
		mod_id = __truncate_mod_id(mod_id)
		for section in configuration:
			section = __truncate_section(section)
			var sect_name : String = mod_id + "/" + section
			var sect_data = configuration[section]
			
			if not sect_name in settings:
				settings[sect_name] = {}
				made_change = true
			
			for s in sect_data:
				var sr = sect_data[s]
				var current = settings[sect_name].get(s,null)
				if current != sr:
					settings[sect_name][s] = sr
					made_change = true
					if not sect_name in changes:
						changes[sect_name] = []
					changes[sect_name].append(s)
					cfg.set_value(sect_name,s,sr)
		
		
		
		var profile = cfg.get_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name","default")
		cfg.save(cfg_file)
		cfg.save(profiles_dir+profile + ".cfg")
		if made_change:
			__change_made()
			if Loader:
				Loader.saved()
	
	func __store_value(mod_id:String, section:String, key:String, value, cfg_filename : String = "Mod_Configurations" + ".cfg"):
		var made_change : bool = false
		var cfg_folder : String  = "user://cfg/"
		var profiles_dir : String  = "user://cfg/.profiles/"
		var cfg : ConfigFile = ConfigFile.new()
		cfg.load(cfg_folder+cfg_filename)
		var modSection : String = __truncate_to_setting_entry(mod_id,section)
		cfg.set_value(modSection,key,value)
		var profile= cfg.get_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name","default")
		
		if not modSection in settings:
			settings[modSection] = {}
			made_change = true
		var current = settings[modSection].get(key,null)
		if current != value:
			settings[modSection][key] = value
			made_change = true
		cfg.save(cfg_folder+cfg_filename)
		cfg.save(profiles_dir+profile + ".cfg")
		if made_change:
			if not modSection in changes:
				changes[modSection] = []
			changes[modSection].append(key)
			__change_made()
			if Loader:
				Loader.saved()
	
	func __get_config(mod_id, cfg_filename : String = "Mod_Configurations" + ".cfg") -> Dictionary:
		var cfg_folder : String  = "user://cfg/"
		var dictionary : Dictionary = {}
		mod_id = __truncate_mod_id(mod_id)
		if settingsHash:
			for section in settings:
				var split : PoolStringArray = section.split("/")
				if split[0] == mod_id:
					var sub : Dictionary = {}
					var sec = settings[section].duplicate(true)
					for key in sec:
						sub.merge({key:sec[key]})
					dictionary.merge({split[1]:sub})
		else:
			var cfg:ConfigFile = ConfigFile.new()
			var error:int = cfg.load(cfg_folder+cfg_filename)
			if error != OK:
				return {}
			var config_sections = cfg.get_sections()
			for section in config_sections:
				var split:PoolStringArray = section.split("/")
				if split[0] == mod_id:
					var sub : Dictionary = {}
					var keys:Array = cfg.get_section_keys(section)
					for key in keys:
						var value = cfg.get_value(section, key)
						sub.merge({key:value})
					dictionary.merge({split[1]:sub})
		return dictionary
	
	func __get_value(mod_id: String, section: String, key: String, cfg_filename : String = "Mod_Configurations" + ".cfg"):
		var cfg_folder : String  = "user://cfg/"
		var full : String  = __truncate_to_setting_entry(mod_id,section)
		
		if settingsHash:
			if full in settings:
				if key in settings[full]:
					var out = settings[full][key]
					var tout:int = typeof(out)
					if tout == TYPE_ARRAY or tout == TYPE_DICTIONARY:
						return out.duplicate(true)
					return out
				return null
			return null
		else:
			var cfg:ConfigFile = ConfigFile.new()
			var error:int = cfg.load(cfg_folder+cfg_filename)
			if error != OK:
				pointers.l("HevLib Config File: Error loading settings %s" % error,"pointers.ConfigDriver")
				return null
			
			if cfg.has_section(full):
				var keys : Array = cfg.get_section_keys(full)
				if key in keys:
					var data = cfg.get_value(full,key)
					return data
				return null
			return null
	
	func pushCFG(cfg_filename : String = "Mod_Configurations" + ".cfg"):
		var cfg_file : String  = "user://cfg/" + cfg_filename
		var current_config : Dictionary = __config_parse(cfg_file)
		settings = current_config.duplicate(true)
		settingsHash = settings.hash()
		__change_made()
		
	
	func __establish_connection(method: String, node: Object, type: String = "config", input_method: String = "input_changed"): # Type accepts "config", "input", or "both"
		match type.to_lower():
			"config":
				if node.has_method(method):
					if not is_connected("config_changed",node,method):
						connect("config_changed",node,method)
					else:
						pointers.l("node %s is already connected with the method '%s'" % [str(node),method],"pointers.ConfigDriver")
				else:
					pointers.l("node %s does not have the method '%s'" % [str(node),method],"pointers.ConfigDriver")
			"input":
				if node.has_method(method):
					if not is_connected("input_changed",node,method):
						connect("input_changed",node,method)
					else:
						pointers.l("node %s is already connected with the method '%s'" % [str(node),method],"pointers.ConfigDriver")
				else:
					pointers.l("node %s does not have the method '%s'" % [str(node),method],"pointers.ConfigDriver")
			"both":
				if node.has_method(method):
					if not is_connected("input_changed",node,input_method):
						connect("input_changed",node,input_method)
					else:
						pointers.l("node %s is already connected with the method '%s'" % [str(node),method],"pointers.ConfigDriver")
					if not is_connected("config_changed",node,method):
						connect("config_changed",node,method)
					else:
						pointers.l("node %s is already connected with the method '%s'" % [str(node),method],"pointers.ConfigDriver")
				else:
					pointers.l("node %s does not have the method '%s'" % [str(node),method],"pointers.ConfigDriver")
	func __remove_connection(method: String, node: Object, type: String = "config", input_method: String = "input_changed"): # Type accepts "config", "input", or "both"
		match type.to_lower():
			"config":
				if node.has_method(method):
					if is_connected("config_changed",node,method):
						disconnect("config_changed",node,method)
					else:
						pointers.l("node %s is already connected with the method '%s'" % [str(node),method],"pointers.ConfigDriver")
				else:
					pointers.l("node %s does not have the method '%s'" % [str(node),method],"pointers.ConfigDriver")
			"input":
				if node.has_method(method):
					if is_connected("input_changed",node,method):
						disconnect("input_changed",node,method)
					else:
						pointers.l("node %s is already connected with the method '%s'" % [str(node),method],"pointers.ConfigDriver")
				else:
					pointers.l("node %s does not have the method '%s'" % [str(node),method],"pointers.ConfigDriver")
			"both":
				if node.has_method(method):
					if is_connected("input_changed",node,input_method):
						disconnect("input_changed",node,input_method)
					else:
						pointers.l("node %s is already connected with the method '%s'" % [str(node),method],"pointers.ConfigDriver")
					if is_connected("config_changed",node,method):
						disconnect("config_changed",node,method)
					else:
						pointers.l("node %s is already connected with the method '%s'" % [str(node),method],"pointers.ConfigDriver")
				else:
					pointers.l("node %s does not have the method '%s'" % [str(node),method],"pointers.ConfigDriver")
		
	
	func __load_configs(cfg_filename : String = "Mod_Configurations" + ".cfg"):
		var default_binds : Dictionary = pointers.Keymapping.__get_formatted_vanilla_binds()
		var dir:Directory = Directory.new()
		var c:ConfigFile = ConfigFile.new()
		var keybinds_cache : String  = "user://cache/.HevLib_Cache/Keybinds/"
		var cfg_file : String  = "user://cfg/" + cfg_filename
		var profiles_dir : String  = "user://cfg/.profiles/"
		var profiles_setter : String  = ".profiles.ini"
		dir.make_dir_recursive(profiles_dir)
		dir.make_dir_recursive(keybinds_cache)
		file.open(keybinds_cache + "vanilla_binds.json",File.WRITE)
		file.store_string(JSON.print(default_binds))
		file.close()
		file.open(keybinds_cache + "defined_control_configs.json",File.WRITE)
		file.store_string("{}")
		file.close()
		if not file.file_exists(profiles_dir + profiles_setter):
			c.clear()
			c.set_value("profiles","selected","Default")
			c.save(profiles_dir + profiles_setter)
			c.clear()
		if not file.file_exists(cfg_file):
			file.open(cfg_file,File.WRITE)
			file.store_string("")
			file.close()
		c.load(profiles_dir + profiles_setter)
		var desired_profile = c.get_value("profiles","selected","Default")
		c.clear()
		c.load(cfg_file)
		var current_profile = c.get_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name","Default")
		var profile_is_current:bool = true
		if current_profile != desired_profile:
			profile_is_current = false
			dir.remove(cfg_file)
			for m in pointers.FolderAccess.__fetch_folder_files("user://cfg/.profiles/"):
				if m != ".profiles.ini":
					c.clear()
					c.load(profiles_dir + m)
					var this_profile = c.get_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name")
					if this_profile == desired_profile:
						dir.copy(profiles_dir + m,cfg_file)
						profile_is_current = true
					c.clear()
					c.load(cfg_file)
		if not profile_is_current:
			c.clear()
			c.set_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name",desired_profile)
			c.save(cfg_file)
		
		var f : Dictionary = pointers.ManifestV2.__get_mod_data()
		var mod_entries : Dictionary = f["mods"]
		pointers.l("[%s] mod entries found" % mod_entries.size(),"pointers.ConfigDriver")
		var disabled_modlets:Dictionary = pointers.ManifestV2.__get_disabled_modlets()
		var DMIDs:PoolStringArray = PoolStringArray()
		for i in disabled_modlets:
			DMIDs.append(disabled_modlets[i])
		pointers.l("[%s] disabled modlets found: [%s]" % [disabled_modlets.size(),",".join(DMIDs)],"pointers.ConfigDriver")
		var configs : Dictionary = {}
		var current_config : Dictionary = __config_parse(cfg_file)
		for mod in mod_entries:
			var manifest : Dictionary = mod_entries[mod]["manifest"]
			var has_manifest:bool = manifest["has_manifest"]
			if has_manifest:
				var mod_name : String  = mod_entries[mod]["name"]
				var manifest_version : float = float(manifest["manifest_version"])
				if manifest_version > 2.0:
					var cfg : Dictionary = manifest["manifest_data"]["configs"]
					if not hash(cfg) == hash({}):
						configs.merge({mod_name:cfg})
		pointers.l("config contains [%s] mods" % configs.size(),"pointers.ConfigDriver")
		for mod in configs:
			var data : Dictionary = configs[mod]
			mod = __truncate_mod_id(mod)
			for section in data:
				var sectData : Dictionary = data[section]
				var sect : String  = mod + "/" + __truncate_section(section)
				if not sect in current_config:
					current_config.merge({sect:{}})
				for key in sectData:
					var key_data : Dictionary = sectData[key]
					if typeof(key_data) == TYPE_DICTIONARY:
						var type : String  = key_data.get("type","")
						if not type:
							continue
						type = type.to_lower()
						if key in current_config[sect]:
							if type == "input":
								var val : Dictionary = current_config[sect]
								for b in val:
									var out : Array = []
									for a in val[b]:
										if typeof(a) == TYPE_STRING:
											a = [a]
										out.append(a)
									current_config[sect][b] = out
						else:
							match type:
								"action":
									current_config[sect].merge({key:key_data.get("method","_pressed")})
								"input":
									var df : Array = key_data["default"]
									var out : Array = []
									for a in df:
										if typeof(a) == TYPE_STRING:
											a = [a]
										out.append(a)
									current_config[sect].merge({key:out})
								_:
									if "default" in key_data:
										current_config[sect].merge({key:key_data["default"]})
								
		if not "profile_name" in current_config.get("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS",{}):
			current_config["HevLib/HEVLIB_CONFIG_SECTION_DRIVERS"]["profile_name"] = "Default"
		for section in current_config:
			for key in current_config[section]:
				c.set_value(section,key,current_config[section][key])
		settings = current_config.duplicate(true)
		settingsHash = settings.hash()
		__change_made()
		c.save(cfg_file)
		c.save(profiles_dir + current_config.get("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS",{}).get("profile_name","Default") + ".cfg")
		pointers.l("loaded [%s] mod configurations" % configs.size(),"pointers.ConfigDriver")
		var actionList : Array = InputMap.get_actions()
		for mod in configs:
			pointers.l("inspecting [%s]" % mod,"pointers.ConfigDriver")
			var data = __get_config(mod)
			pointers.l("found [%s] sections" % data.size(),"pointers.ConfigDriver")
			for section in configs[mod]:
				pointers.l("inspecting section [%s]" % section,"pointers.ConfigDriver")
				var sectData = configs[mod][section]
				for key in sectData:
					var key_data = sectData[key]
					pointers.l("found entry [%s] of type [%s] with a default of [%s]" % [key,key_data["type"],key_data.get("default","Null")],"pointers.ConfigDriver")
					if key_data["type"].to_lower() == "input":
						var p = __get_value(mod,section,key)
						pointers.l("value of [%s] is [%s]" % [key,p],"pointers.ConfigDriver")
						var default = key_data.get("default",[])
						pointers.l("[%s] default is [%s]" % [key,default],"pointers.ConfigDriver")
						var b = []
						for h in p:
							if typeof(h) == TYPE_STRING:
								h = [h]
							b.append(h)
						p = b
						var deadzone = key_data.get("deadzone",0.5) # Control deadzone value
						
						var opts = pointers.Keymapping.__get_opts_from_key_data(key_data)
						if p == null:
							p = default
						var addAction = true
						if not key in actionList:
							pointers.l("Adding input key [%s]" % key,"pointers.ConfigDriver")
							InputMap.add_action(key,deadzone)
							actionList.append(key)
						else:
							pointers.l("Input key [%s] already exists, skipping" % key,"pointers.ConfigDriver")
						pointers.Keymapping.__load_input_data(key,p,opts)
		
	
	func __load_inputs_from_string_array(key:String, strings: Array):
		for i in strings:
			if i.begins_with("Mouse "):
				var event:InputEventMouseButton = InputEventMouseButton.new()
				event.button_index = int(i.split("Mouse ")[1])
				if not InputMap.action_has_event(key,event):
					pointers.l("Adding input event [%s] for [%s]" % [i,key],"pointers.ConfigDriver")
					InputMap.action_add_event(key, event)
				else:
					pointers.l("Input event [%s] for [%s] already exists, skipping" % [i,key],"pointers.ConfigDriver")
			if i.begins_with("JoyButton "):
				var event:InputEventJoypadButton = InputEventJoypadButton.new()
				event.button_index = int(i.split("JoyButton ")[1])
				if not InputMap.action_has_event(key,event):
					pointers.l("Adding input event [%s] for [%s]" % [i,key],"pointers.ConfigDriver")
					InputMap.action_add_event(key, event)
				else:
					pointers.l("Input event [%s] for [%s] already exists, skipping" % [i,key],"pointers.ConfigDriver")
			if i.begins_with("JoyAxis "):
				var event:InputEventJoypadMotion = InputEventJoypadMotion.new()
				event.axis = abs(int(i.split("JoyAxis ")[1]))
				if i.split("JoyAxis ")[1].begins_with("-"):
					event.axis_value = -1.0
				else:
					event.axis_value = 1.0
				if not InputMap.action_has_event(key,event):
					pointers.l("Adding input event [%s] for [%s]" % [i,key],"pointers.ConfigDriver")
					InputMap.action_add_event(key, event)
				else:
					pointers.l("Input event [%s] for [%s] already exists, skipping" % [i,key],"pointers.ConfigDriver")
				
			else:
				var event:InputEventKey = InputEventKey.new()
				event.scancode = OS.find_scancode_from_string(i)
				if not InputMap.action_has_event(key,event):
					pointers.l("Adding input event [%s] for [%s]" % [i,key],"pointers.ConfigDriver")
					InputMap.action_add_event(key, event)
				else:
					pointers.l("Input event [%s] for [%s] already exists, skipping" % [i,key],"pointers.ConfigDriver")
		
	func set_button_focus(button,check_button):
		var parent = button.get_parent()
		var children = parent.get_children()
		var pos = button.get_position_in_parent()
		var icon_button
		var reset_button
		icon_button = button.get_node("Label/LABELBUTTON")
		reset_button = button.get_node("reset")
		
		if children.size() == 1:
			icon_button.focus_neighbour_top = "."
			reset_button.focus_neighbour_top = "."
			check_button.focus_neighbour_top = "."
		elif pos == 0:
			icon_button.focus_neighbour_top = "."
			reset_button.focus_neighbour_top = "."
			check_button.focus_neighbour_top = "."
			var p1 = parent.get_child(pos+1)
			if p1.name != "BottomSeparatorForToolTipsPlsIgnore":
				var script_path : String  = p1.get_script().get_path()
				
				
				icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
				reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
				
				match script_path:
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Button"))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
						var style = parent.get_child(pos+1).style
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("LineEdit"))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("OptionButton"))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
					_:
						breakpoint
		elif pos == children.size() - 1:

			var script_path : String  = parent.get_child(pos-1).get_script().get_path()
			
			
			icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
			reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
			match script_path:
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos - 1).get_node("Button"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
					var style = parent.get_child(pos-1).style
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node_or_null(style))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("LineEdit"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("OptionButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
				_:
					breakpoint
		else:
			var script_path : String  = parent.get_child(pos-1).get_script().get_path()
			
			icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
			reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
			match script_path:
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos - 1).get_node("Button"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
					var style = parent.get_child(pos-1).style
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node_or_null(style))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("LineEdit"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("OptionButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
				_:
					breakpoint
			
			var p2 = parent.get_child(pos+1)
			if p2.name != "BottomSeparatorForToolTipsPlsIgnore":
				var script_path2 = p2.get_script().get_path()
				
			
				icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
				reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
				match script_path2:
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Button"))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
						var style = parent.get_child(pos+1).style
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("LineEdit"))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("OptionButton"))
					"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
						check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
					_:
						breakpoint
	var mk_c : bool = false
	func __change_made():
		mk_c = true
	
	func handle_change_made():
		var shs:int = settings.hash()
		if shs != settingsHash:
			__input_change_made()
			__subscribed_changes()
			emit_signal("config_changed")
			settingsHash = shs
		mk_c = false
	
	func __subscribed_changes():
		for i in changes:
			if i in subscriptions:
				var sub = subscriptions[i]
				var s = i.split("/")
				var entries = changes[i]
				for entry in entries:
					if entry in sub:
						var val = __get_value(s[0],s[1],entry)
						var out = sub[entry]
						for o in out:
							var obj = o[0]
							if Tool.ov(obj):
								obj.callv(o[1],[val])
		changes.clear()
	
	var cached_input_config_names : Dictionary = {}
	
	func __input_change_made():
		var ic : Array = []
		var inputnames : Dictionary = {}
		if cached_input_config_names:
			inputnames = cached_input_config_names
		else:
			var ax : Dictionary = pointers.ManifestV2.__get_manifest_cache()
			for sect in ax:
				var dv : Dictionary = ax[sect]
				var dl : Dictionary = dv.get("configs",{})
				for sec in dl:
					var sv : Dictionary = dl[sec]
					for setting in sv:
						var data : Dictionary = sv[setting]
						if data.get("type").to_lower() == "input":
							var n : String  = __truncate_mod_id(dv["mod_information"]["name"])
							if not n in cached_input_config_names:
								cached_input_config_names[n] = {}
							if not sec in cached_input_config_names[n]:
								cached_input_config_names[n][sec] = []
							cached_input_config_names[n][sec].append(setting)
			inputnames = cached_input_config_names
		for n in inputnames:
			var nd : Dictionary = inputnames[n]
			for sec in nd:
				var sc : Array = nd[sec]
				for setting in sc:
					var vf : Array = __get_value(n,sec,setting)
					var out : Array = []
					var resave:bool = false
					for a in vf:
						if typeof(a) == TYPE_STRING:
							a = [a]
							resave = true
						out.append(a)
					if resave:
						__store_value(n,sec,setting,out)
					ic.append(str(n)+str(sec)+str(setting)+str(out))
		var shs:int = ic.hash()
		if shs != settingsInputHash:
			emit_signal("input_changed")
			settingsInputHash = shs
	
	func __subscribe_to_setting_change(method: String,object: Object,id: String,section: String,setting: String):
		if object.has_method(method):
			var top : String  = __truncate_to_setting_entry(id,section)
			if not top in subscriptions:
				subscriptions[top] = {}
			if not setting in subscriptions[top]:
				subscriptions[top][setting] = []
			var do:bool = true
			for item in subscriptions[top][setting]:
				if item[0] == object:
					if item[1] == method:
						do = false
			if do:
				subscriptions[top][setting].append([object,method])
		else:
			pointers.l("node %s does not have the method '%s'" % [str(object),method],"pointers.ConfigDriver")
			
	
	func __disconnect_subscription(method: String,object: Object,id: String,section: String,setting: String):
		var top : String  = __truncate_to_setting_entry(id,section)
		if top in subscriptions:
			if setting in subscriptions[top]:
				for item in subscriptions[top][setting]:
					if item[0] == object:
						if item[1] == method:
							subscriptions[top][setting].erase(item)
	
	func __truncate_mod_id(mod_id:String) -> String:
		mod_id = pointers.DataFormat.__array_to_string(mod_id.split("/"))
		mod_id = pointers.DataFormat.__array_to_string(mod_id.split(" "))
		return mod_id
	
	func __truncate_section(section:String) -> String:
		return pointers.DataFormat.__array_to_string(section.split("/"))
	
	func __truncate_to_setting_entry(mod_id:String,section:String) -> String:
		var sect_name : String  = __truncate_mod_id(mod_id) + "/" + __truncate_section(section)
		return sect_name
	
	func __validate_dictionary(data_dict : Dictionary,check_config : bool = true, check_requirements : bool = true, check_incompatibilities : bool = true, config_entry_override : String = "config", mod_requirements_entry_override : String = "mod_requirements", mod_incompatibilities_entry_override : String = "mod_incompatibilities"):
		var how:bool = true
		if check_config and config_entry_override in data_dict and data_dict[config_entry_override] is Dictionary:
			var cfg : Dictionary = data_dict[config_entry_override]
			var config_id : String  = cfg.get("id",cfg.get("mod",cfg.get("mod_id","")))
			var config_section : String  = cfg.get("section","")
			var config_setting : String  = cfg.get("entry",cfg.get("setting",cfg.get("key",cfg.get("value",cfg.get("opt","")))))
			var invert_config:bool = cfg.get("invert_config",cfg.get("invert",false))
			if config_id and config_section and config_setting:
				var cfg_opt = __get_value(config_id,config_section,config_setting)
				if cfg_opt != null:
					if invert_config:
						if cfg_opt:
							how = false
					else:
						if !cfg_opt:
							how = false
		if how:
			var current_mod_ids : Array = pointers.ManifestV2.__get_mod_ids()
			var allowFromMods:bool = true
			if check_requirements and mod_requirements_entry_override in data_dict and data_dict[mod_requirements_entry_override] is Array:
				var needs : Array = data_dict[mod_requirements_entry_override]
				var can:int = 0
				for a in needs:
					for f in a:
						var has:bool = false
						if f in current_mod_ids:
							has = true
						if has:
							can += 1
				allowFromMods = can == needs.size()
			if allowFromMods:
				var allowFromMods2 = true
				if check_incompatibilities and mod_incompatibilities_entry_override in data_dict and data_dict[mod_incompatibilities_entry_override] is Array:
					var needs : Array = data_dict[mod_incompatibilities_entry_override]
					var can:int = 0
					for a in needs:
						var cv:bool = false
						for f in a:
							var has = false
							if f in current_mod_ids:
								has = true
							if has:
								cv = true
						if cv:
							can += 1
					allowFromMods2 = can != needs.size()
				if allowFromMods2:
					return true
		return false
	
	func __config_parse(file_path: String) -> Dictionary:
		if not file.file_exists(file_path) and not ResourceLoader.exists(file_path):
			return {}
		var cfg:ConfigFile = ConfigFile.new()
		file.open(file_path,File.READ)
		var txt : String  = file.get_as_text()
		file.close()
		cfg.parse(txt)
		var cfg_sections : Array = cfg.get_sections()
		var cfg_dictionary : Dictionary = {}
		for section in cfg_sections:
			var data : Dictionary = {}
			var keys : Array = cfg.get_section_keys(section)
			for key in keys:
				var item = cfg.get_value(section,key)
				data.merge({key:item})
			cfg_dictionary.merge({section:data})
		return cfg_dictionary
	
	func __config_store(dict : Dictionary,filepath:String):
		var cfg:ConfigFile = ConfigFile.new()
		for section in dict:
			var keys = dict[section]
			for key in keys:
				cfg.set_value(section,key,keys[key])
		cfg.save(filepath)
	
	
	
	
class _DataFormat:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"Methods used to assist with the manipulation and loading of data",
			"methods":{
				"__array_to_string":{
					"description":"Converts an array into a string. Unlike String.join(), accepts any array type and will convert components to a string as best as possible.",
					"args":[
						"arr -> (Array) input array to be concatenated into a string"
					],
					"return":[
						"String containing the concatenated array"
					]
				},
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
						"cfgs_to_ignore -> (Array) any keys within the config to remove from the search. Due to the way this works, it's highly recommended to do a deep duplication of the dictionary before searching."
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
				"__compile_and_override_script":{
					"description":"Compiles a script and overrides it. Similar to the installScriptExtension method used in ModMain scripts",
					"args":[
						"source_code -> (String) source code for the script override.",
					],
				},
				"__compile_and_override_script_with_scene":{
					"description":"Similar to __compile_and_override_script, additionally creates and updates one or more scenes after overriding the script in case script needs to have scenes reloaded to apply the update.",
					"args":[
						"source_code -> (String) source code for the script override.",
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
				"__file_exists":{
					"description":"An all-encompassing method to determine if a file exists in the filesystem, without the need to query File and ResourceLoader directly",
					"args":[
						"file_path -> (String) the file path to the desired resource to check. Can be both relative, global, or OS-global",
					],
					"return":[
						"Bool for whether the file at file_path exists or not."
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
			}
		}
	
	var file:File = File.new()
	
	var pointers
	func _init(f):
		pointers = f
		urlRegex.compile("^https?:\\/\\/(?:www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,63}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&\\/=]*)$")
	
	func __array_to_string(arr: Array) -> String:
		var s : String  = ""
		for i in arr:
			s += String(i)
		return s
	
	func __rotate_point(point : Vector2, angle : float, degrees : bool = true) -> Vector2:
		if degrees:
			angle = deg2rad(angle)
		angle = -angle
		var x:float = point[0]
		var y:float = point[1]
		var xca:float = x*cos(angle)
		var ysa:float = y*sin(angle)
		var yca:float = y*cos(angle)
		var xsa:float = x*sin(angle)
		return Vector2(xca-ysa,yca+xsa)
	
	func __get_vanilla_version() -> Array:
		var version : Array = [1,0,0]
		var lb : Node = load("res://VersionLabel.tscn").instance()
		var textData : String  = lb.text
		lb.free()
		if textData:
			var data:PoolStringArray = textData.split(".")
			version[0] = int(data[0])
			version[1] = int(data[1])
			version[2] = int(data[2])
		return version
	
	func __sift_dictionary(dictionary: Dictionary,search_keys: Array) -> Array:
		var returning_keys : Array = []
		for key in dictionary:
			if key in search_keys:
				returning_keys.append(key)
			var kdata = dictionary[key]
			if kdata in search_keys:
				returning_keys.append(kdata)
			if typeof(kdata) == TYPE_DICTIONARY:
				returning_keys.append_array(__sift_dictionary(kdata,search_keys))
		return returning_keys
	
	func __convert_arr_to_vec2arr(array: Array) -> PoolVector2Array:
		var converted:PoolVector2Array = PoolVector2Array([])
		var size = array.size()
		if size % 2 == 1:
			pointers.l("Cannot convert array to PoolVector2Array with an odd number of entries","pointers.DataFormat")
			return PoolVector2Array([])
		var index:int = 0
		while index < size:
			var aRaw = array[index]
			var bRaw = array[index + 1]
			if not (aRaw is float or aRaw is int or aRaw is String):
				pointers.l("Cannot convert type %s for PoolVector2Array" % aRaw,"pointers.DataFormat")
				return PoolVector2Array([])
			if not (bRaw is float or bRaw is int or bRaw is String):
				pointers.l("Cannot convert type %s for PoolVector2Array" % bRaw,"pointers.DataFormat")
				return PoolVector2Array([])
			var a:float = float(aRaw)
			var b:float = float(bRaw)
			var pooling:Vector2 = Vector2(a,b)
			converted.append(pooling)
			index += 2
		return converted
	
	func __compare_versions(primary_major : int,primary_minor : int,primary_bugfix : int, compare_major : int, compare_minor : int, compare_bugfix : int) -> bool:
		if primary_major < compare_major:
			return false
		elif primary_major == compare_major:
			if primary_minor < compare_minor:
				return false
			elif primary_minor == compare_minor:
				if primary_bugfix < compare_bugfix:
					return false
		return true
	
	func __sift_ship_config(dictionary: Dictionary,search_keys: Array,cfgs_to_ignore:Array,parent = "") -> Array:
		for i in cfgs_to_ignore:
			dictionary.erase(i)
		var arr : Array = []
		var splitter : String  = "."
		var prefab : String  = ""
		if parent != "":
			prefab = parent + splitter
		for key in dictionary:
			var kdata = dictionary[key]
			var p : String  = prefab + key
			match typeof(kdata):
				TYPE_STRING:
					if kdata in search_keys:
						arr.append(p + splitter + kdata)
				TYPE_DICTIONARY:
					arr.append_array(__sift_ship_config(kdata,search_keys,[],p))
		return arr
	
	func __get_script_constant_map_without_load(script_path : String) -> Dictionary:
		var filepath : String  = "user://cache/.HevLib_Cache/Variable_Fetch/"
		var pathway : Array = __trim_scripts(script_path)
		if pathway[2].size() == 0:
			return {}
		var dict : Dictionary = {}
		var l : Dictionary = __compile_script(pathway[0]).get_script_constant_map()
		for i in pathway[2]:
			dict[i] = l[i]
		return dict
	
	func __get_script_variables_without_load(script_path : String) -> Dictionary:
		var filepath : String  = "user://cache/.HevLib_Cache/Variable_Fetch/"
		var pathway : Array = __trim_scripts(script_path)
		if pathway[1].size() == 0:
			return {}
		var dict : Dictionary = {}
		var l = __compile_script_object(pathway[0])
		for i in pathway[1]:
			dict[i] = l.get(i)
		return dict
		
	const function_prefixes = ["func ","static func ","remote func ","master func ","puppet func ","remotesync func ","mastersync func ","puppetsync func ","sync func "]
	const all_prefixes = ["func ","static func ","remote func ","master func ","puppet func ","remotesync func ","mastersync func ","puppetsync func ","sync func ","onready ","var ","signal ","const ","export ","extends "]
	func __trim_scripts(file_path : String, get_detailed_operands : bool = false, trim_unnecessary_newlines : bool = false, recurse_through_base_scripts : bool = true):
		if __load_if_can(file_path):
			var script_source = __get_load()
			if script_source:
				return __trim_script_object(script_source,get_detailed_operands,trim_unnecessary_newlines,recurse_through_base_scripts)
		return ["extends Node",[],[],[],[],[],[],[]]
	
	func __trim_script_object(script_source : Script, get_detailed_operands : bool = false, trim_unnecessary_newlines : bool = false, recurse_through_base_scripts : bool = true):
		var concat : String = ""
		var var_names : Array = []
		var const_names : Array = []
		var method_names : Array = []
		var signal_names : Array = []
		var method_values : Array = []
		var method_output_type : Array = []
		var signal_values : Array = []
		if script_source:
			var extend_this:bool = true
			if recurse_through_base_scripts:
				var base_script:Script = script_source.get_base_script()
				if base_script:
					var base_data : Array = __trim_script_object(base_script,get_detailed_operands,trim_unnecessary_newlines,recurse_through_base_scripts)
					concat += base_data[0]
					if concat.find("extends ") > -1:
						extend_this = false
					if not concat.ends_with("\n"):
						concat += "\n"
					for i in base_data[1]:
						if not i in var_names:
							var_names.append(i)
					for i in base_data[2]:
						if not i in const_names:
							const_names.append(i)
					for f in range(base_data[3].size()):
						var i = base_data[3][f]
						if not i in signal_names:
							signal_names.append(i)
							signal_values.append(base_data[5][f])
					for f in range(base_data[4].size()):
						var i = base_data[4][f]
						if not i in method_names:
							method_names.append(i)
							method_values.append(base_data[6][f])
							method_output_type.append(base_data[7][f])
			var data : String  = script_source.get_source_code()
			var streaming:bool = false
			var this_stream : String = ""
			var lines:PoolStringArray = data.split("\n")
			for line in lines:
				var result : String = ""
				var is_part_of_string:bool = false
				var prev_char_escape:bool = false
				while line != "":
					var part:String = line.substr(0,1)
					if part == "\\":
						prev_char_escape = !prev_char_escape
					else:
						prev_char_escape = false
					if part == "\"" and not prev_char_escape:
						is_part_of_string = !is_part_of_string
					if part == "#" and (not is_part_of_string and not prev_char_escape):
						break
					line.erase(0,1)
					result += part
				line = result
				var has_prefix:bool = false
				var has_sig:bool = false
				for prefix in function_prefixes:
					if line.begins_with(prefix):
						has_prefix = true
				if line.begins_with("signal "):
					has_sig = true
				if has_prefix:
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var av:PoolStringArray = line.split("func ")[1].split("(")
					var mname : String  = av[0]
					if get_detailed_operands:
						var operands : String = line.split(mname)[1].strip_edges()
						var os:PoolStringArray = operands.split("->")
						var outputType : String = ""
						if os.size() > 1:
							outputType = os[1].rstrip(":")
							operands = os[0].strip_edges()
						if operands.begins_with("("):
							operands = operands.substr(1, operands.length())
						if operands.ends_with(":"):
							operands = operands.substr(0, operands.length() - 1)
						if operands.ends_with(")"):
							operands = operands.substr(0,operands.length() - 1)
						var opnames : String  = ""
						var opvalues : Array = []
						var thisOpValue : String  = ""
						var colonDelim:bool = false
						var bracketDelim:bool = false
						for i in operands:
							if not colonDelim and i == ":":
								colonDelim = true
							if colonDelim and i == ",":
								colonDelim = false
							if not bracketDelim and i == "(":
								bracketDelim = true
							if bracketDelim and i == ")":
								bracketDelim = false
							if not colonDelim and not bracketDelim:
								opnames += i
							if not bracketDelim and i == ",":
								opvalues.append(thisOpValue.strip_edges())
								thisOpValue = ""
							else:
								thisOpValue += i
						if thisOpValue:
							opvalues.append(thisOpValue.strip_edges())
							thisOpValue = ""
						method_values.append(opvalues)
						method_output_type.append(outputType.strip_edges())
					method_names.append(mname)
				elif has_sig:
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var av:PoolStringArray = line.split("signal ")[1].split("(")
					var sname : String  = av[0]
					if get_detailed_operands:
						var op = []
						if av.size() > 1:
							var operands : String  = av[1].rstrip(")")
							if operands:
								for o in operands.split(","):
									op.append(o.strip_edges())
						signal_values.append(op)
					signal_names.append(sname)
				elif line.begins_with("const "):
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var cname : String  = line.split("=",false)[0].strip_edges().split("const ",true)[1].strip_edges().split(":",false)[0].strip_edges()
					const_names.append(cname)
					streaming = true
				elif line.begins_with("var "):
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var vname : String  = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
					var_names.append(vname)
					streaming = true
				elif line.begins_with("export ") and " var " in line:
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var vname : String  = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
					var_names.append(vname)
					streaming = true
				elif line.begins_with("onready ") and " var " in line:
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var vname : String  = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
					var_names.append(vname)
					streaming = true
				elif line.begins_with("extends "):
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					if extend_this:
						streaming = true
				if streaming:
					this_stream = this_stream + "\n" + line
			if streaming:
				concat = concat + this_stream.strip_edges() + "\n"
				this_stream = ""
				streaming = false
		if trim_unnecessary_newlines:
			var reconcat : String  = ""
			for line in concat.split("\n"):
				var newline:bool = false
				var ls : String  = line.strip_edges()
				for a in all_prefixes:
					if ls.begins_with(a):
						newline = true
				if newline and reconcat:
					ls = "\n" + ls
				reconcat += ls
			concat = reconcat
		return [concat if concat !="" else "extends Node",var_names,const_names,signal_names,method_names,signal_values,method_values,method_output_type]
	
	func __factorial(n:int) -> int:
		var holdvalue:int = 0
		var boolis:bool = true
		var s:int = sign(n)
		n = abs(n)
		if n == 0 or n == 1:
			holdvalue = 1
		else:
			while n > 0:
				if boolis:
					boolis = false
					holdvalue = n
				else:
					holdvalue = holdvalue * n
				n = n-1
		return (holdvalue * s)
	
	func __get_unique_pairs(max_value: int) -> Array:
		var pairs : Array = []
		for i in range(max_value + 1):
			for j in range(i + 1, max_value):
				pairs.append(PoolIntArray([i, j]))
		return pairs
	
	var compiled_scripts : Dictionary = {}
	var compiled_script_object_storage : Dictionary = {}
	
	func __compile_script(source_code : String) -> Script:
		var shash:int = hash(source_code)
		pointers.l("Compiling script resource [%d]" % shash,"pointers.DataFormat")
		if shash in compiled_scripts:
			pointers.l("Fetching from cache","pointers.DataFormat")
			return compiled_scripts[shash]
		var out:GDScript = GDScript.new()
		out.set_source_code(source_code)
		out.reload()
		compiled_scripts[shash] = out
		return out
	
	
	func __compile_script_object(source_code : String, params = [],new_object : bool = false) -> Script:
		if not params is Array:
			params = [params]
		var shash : String  = ""
		if params:
			var parStr : String  = str(params)
			shash = str(hash(source_code)) + "_" + str(hash(parStr))
		else:
			shash = str(hash(source_code))
		pointers.l("Compiling script as object @ [%s]; parameters: %s, new object: %s" % [shash,str(params),str(new_object)],"pointers.DataFormat")
		if not new_object and shash in compiled_script_object_storage:
			pointers.l("Fetching from cache","pointers.DataFormat")
			return compiled_script_object_storage[shash]
		
		var gd:GDScript = GDScript.new()
		gd.set_source_code(source_code)
		gd.reload()
		var out
		if params:
			var f = funcref(gd,"new")
			var param_part = "_%d"
			var pb = ""
			var pd = ""
			for i in range(params.size()):
				var p = params[i]
				var pv = param_part % i
				if pb:
					pb += "," + pv
				else:
					pb = pv
				if pd:
					pd += "\n\tvar %s = arr[%d]" % [pv,i]
				else:
					pd = "\n\tvar %s = arr[%d]" % [pv,i]
			var sv = "static func parse(ref,arr):%s\n\treturn ref.call_func(%s)" % [pd,pb]
			
			var g:GDScript = GDScript.new()
			g.set_source_code(sv)
			g.reload()
			g.new()
			out = g.parse(f,params)
		else:
			out = gd.new()
		compiled_script_object_storage[shash] = out
		return out
	
	var _savedScriptObjects : Array = []
	func __compile_and_override_script(source_code : String) -> void:
		pointers.l("Compiling script of length %s" % str(source_code.length()),"pointers.DataFormat")
		pointers.equipment_modmain.installScriptExtensionFromSource(source_code)
	
	func __compile_and_override_script_with_scene(source_code : String, scene_path = []) -> void:
		if not scene_path is Array and not scene_path is PoolStringArray:
			scene_path = PoolStringArray([scene_path])
		pointers.l("Attempting to compile and override script (with override) with script of length [%s], [%s] scene path(s) to reload" % [source_code.length(),scene_path.size()],"pointers.DataFormat")
		__compile_and_override_script(source_code)
		for i in range(scene_path.size()):
			var sc:String = scene_path[i]
			pointers.l("Passing scene replacement %s/%s to reloader: %s" % [i,scene_path.size(),sc],"pointers.DataFormat")
			__reload_scene(sc)
	
	func __reload_scene(scene_path : String):
		pointers.l("Attempting to reload scene at [%s]" % scene_path,"pointers.DataFormat")
		if __load_if_can(scene_path):
			var scn = __get_load().instance()
			var root : String  = scn.name
			if Tool.validex != null:
				Tool.remove(scn)
			else:
				if is_instance_valid(scn) and not scn.is_queued_for_deletion():
					scn.free()
			var p : String  = "[gd_scene load_steps=2 format=2]\n\n[ext_resource path=\"%s\" type=\"PackedScene\" id=1]\n\n[node name=\"%s\" instance=ExtResource( 1 )]" % [scene_path,root]
			pointers.l("Successfully found data for reloading scene with root [%s], passing to scene replacer" % root,"pointers.DataFormat")
			__replace_scene(p,scene_path)
	
	func __override_script(file_path : String):
		pointers.l("Attempting to install script override at [%s]" % file_path,"pointers.DataFormat")
		if __load_if_can(file_path):
			var sc:String = __get_load().get_source_code()
			pointers.l("Script override successful with length of %s, passing to compiler" % str(sc.length()),"pointers.DataFormat")
			__compile_and_override_script(sc)
	
	func __replace_resource(resource_path:String, original_path:String):
		if not ResourceLoader.exists(resource_path) or not ResourceLoader.exists(original_path):
			pointers.l("Cannot replace resource at [%s] as it either does not exist or is not visible to the engine" % resource_path,"pointers.DataFormat")
			return
		pointers.l("Replacing resource at [%s] with [%s], passing to ModMain" % [original_path,resource_path],"pointers.DataFormat")
		pointers.equipment_modmain.replaceSceneLiteral(resource_path,original_path)
	
	func __replace_scene(scene_data:String,override_path:String = "",scene_file_path:String = "",cache_scene:bool = true) -> PackedScene:
		var scene_replacement : String  = (scene_file_path) if scene_file_path else ("user://cache/.HevLib_Cache/Variable_Fetch/scene_replacement_%d.tscn" % Time.get_ticks_usec())
		pointers.l("__replace scene called with [override: %s / store path: %s / force cache: %s]" % [override_path,scene_replacement,str(cache_scene)],"pointers.DataFormat")
		pointers.FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/Variable_Fetch")
		file.open(scene_replacement,File.WRITE)
		file.store_string(scene_data)
		file.close()
		if override_path and ResourceLoader.exists(override_path):
			pointers.equipment_modmain.replaceSceneLiteral(scene_replacement,override_path)
		var scene : PackedScene = load(scene_replacement)
		if cache_scene and not scene in pointers.equipment_modmain._savedObjects:
			pointers.equipment_modmain._savedObjects.append(scene)
		if scene and scene.can_instance():
			pointers.l("Successfully created scene","pointers.DataFormat")
			return scene
		pointers.l("Scene creation failed","pointers.DataFormat")
		return null
	
	var var_hash : Dictionary = {}
	
	func __convert_var_from_string(string : String, constant = true):
		var shash:int = hash(string + str(constant))
		if shash in var_hash:
			return var_hash[shash]
		var header : String 
		if constant:
			header = "extends Reference\nconst VARIABLE = "
		else:
			header = "extends Reference\nvar VARIABLE = "
		var script = __compile_script_object(header + string)
		var variable = script.VARIABLE
		var_hash[shash] = variable
		return variable
	
	var last_successful_object = null
	var last_load = null
	
	func __load_if_can(filepath : String, override_cache : bool = false, type_hint : String = ""):
		if not filepath:
			return false
		if __file_exists(filepath):
			var obj = ResourceLoader.load(filepath,type_hint,override_cache)
			if obj:
				last_load = obj
				last_successful_object = obj
				return true
		last_load = null
		return false
	
	func __get_load(get_last_successful : bool = false):
		if get_last_successful:
			if not Tool.ovnolock(last_successful_object):
				last_successful_object = null
			return last_successful_object
		if not Tool.ovnolock(last_load):
			last_load = null
		return last_load
	
	func __file_exists(file_path:String) -> bool:
		file_path = ProjectSettings.localize_path(file_path)
		if ResourceLoader.exists(file_path) or file.file_exists(file_path):
			return true
		return false
	
	var urlRegex = RegEx.new()
	func __is_valid_url(URL:String) -> bool:
		var vt = urlRegex.search(URL)
		if vt: return true
		return false
	
	func __loadDLC():
		pointers.l("Preloading DLC as workaround","pointers.DataFormat")
		var DLCLoader:Settings = preload("res://Settings.gd").new()
		DLCLoader.loadDLC()
		DLCLoader.queue_free()
		pointers.l("Finished loading DLC","pointers.DataFormat")

class _DriverManagement:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"Contains methods used to fetch driver information from mods",
			"methods":{
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
			}
		}
	
	
	var pointers
	func _init(f):
		pointers = f
	
	var file:File = File.new()
	
	func __get_drivers(get_ids : Array = []) -> Array:
		var mod_drivers : Array = []
		var mms : Array = pointers.ManifestV2.__get_modmain_files() + pointers.ManifestV2.__get_modlet_files()
		for modmain_path in mms:
			var has_manifest:bool = false
			var manifest_path : String  = ""
			var modFolder : String  = modmain_path.get_base_dir() + "/"
			var modFile : String  = modmain_path.get_file().to_lower()
			if modFile.begins_with("mod") and modFile.ends_with(".manifest"):
				has_manifest = true
				manifest_path = modmain_path
			else:
				for item in pointers.FolderAccess.__fetch_folder_files(modFolder,false,true):
					var modEntryName = item.get_file().to_lower()
					if modEntryName.begins_with("mod") and modEntryName.ends_with(".manifest"):
						has_manifest = true
						manifest_path = item
			
			var this_mod_data : Dictionary = {"drivers":{}}
			var id : String  = ""
			var manifest : Dictionary = {}
			if has_manifest:
				manifest = pointers.ManifestV2.__parse_file_as_manifest(manifest_path)
				id = manifest.get("mod_information",{}).get("id","")
			if id != "":
				this_mod_data.merge({"id":id})
			var mm_prio:int = 0
			if modFile.begins_with("mod") and modFile.ends_with(".manifest"):
				manifest.get("manifest_definitions",{}).get("modlet_priority",0)
			else:
				var modmain : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load(modmain_path)
				if "MOD_PRIORITY" in modmain:
					mm_prio = modmain["MOD_PRIORITY"]
			this_mod_data.merge({"priority":mm_prio})
			
			this_mod_data["drivers"] = __get_drivers_from_modmain_path(modmain_path)
			
			this_mod_data.merge({"mod_directory":modFolder})
			if this_mod_data["drivers"].size() > 0:
				if (get_ids.size()) == 0 or (get_ids.size() > 0 and id in get_ids):
					mod_drivers.append(this_mod_data)
		
		mod_drivers.sort_custom(self,"compare_driver_dictionaries")
		return mod_drivers.duplicate(true)
	
	func compare_driver_dictionaries(a, b):
		var aPrio:int = a.get("priority",0)
		var bPrio:int = b.get("priority",0)
		if aPrio != bPrio:
			return aPrio < bPrio

		
		var aPath : String  = a.get("mod_directory","")
		var bPath : String  = b.get("mod_directory","")
		if aPath != bPath:
			return aPath < bPath

		return false
	
	var driver_get_cache : Dictionary = {}
	
	func __get_drivers_from_modmain_path(file_path: String, get_fresh_drivers: bool = false):
		if not get_fresh_drivers and driver_get_cache.get(file_path):
			return driver_get_cache[file_path].duplicate(true)
		else:
			var this_mod_data : Dictionary = {}
			if not file.file_exists(file_path):
				return {}
			var file_name : String  = file_path.get_file()
			var folder_path : String  = file_path.get_base_dir() + "/"
			var folderCheck : Array = pointers.FolderAccess.__fetch_folder_files(folder_path,true)
			if "HEVLIB_EQUIPMENT_DRIVER_TAGS/" in folderCheck:
				var driverFolder : String  = folder_path + "HEVLIB_EQUIPMENT_DRIVER_TAGS/"
				for driver in pointers.FolderAccess.__fetch_folder_files(driverFolder):
					if not driver in this_mod_data:
						this_mod_data.merge({driver:{}})
					var consts : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
					for i in consts:
						this_mod_data[driver].merge({i:consts[i]})
			if "HEVLIB_MENU/" in folderCheck:
				var driverFolder : String  = folder_path + "HEVLIB_MENU/"
				for driver in pointers.FolderAccess.__fetch_folder_files(driverFolder):
					if not driver in this_mod_data:
						this_mod_data.merge({driver:{}})
					var consts : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
					for i in consts:
						this_mod_data[driver].merge({i:consts[i]})
			if "HEVLIB_MINERAL_DRIVER_TAGS/" in folderCheck:
				var driverFolder : String  = folder_path + "HEVLIB_MINERAL_DRIVER_TAGS/"
				for driver in pointers.FolderAccess.__fetch_folder_files(driverFolder):
					if not driver in this_mod_data:
						this_mod_data.merge({driver:{}})
					var consts : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
					for i in consts:
						this_mod_data[driver].merge({i:consts[i]})
			if "HEVLIB_DRIVERS/" in folderCheck:
				var driverFolder : String  = folder_path + "HEVLIB_DRIVERS/"
				for driver in pointers.FolderAccess.__fetch_folder_files(driverFolder):
					if not driver in this_mod_data:
						this_mod_data.merge({driver:{}})
					var consts : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
					for i in consts:
						this_mod_data[driver].merge({i:consts[i]})
			driver_get_cache[file_path] = this_mod_data.duplicate(true)
			return this_mod_data.duplicate(true)
	
	
	

class _Equipment:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"Contains internal methods used for creating equipment scenes. Use at your own discretion",
			"methods":{
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
						"String containing a full slot item"
					]
				},
			}
		}
	
	var vanilla_equipment : Dictionary = {}
	var vanilla_data = preload("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
	var hardpoint_types : Array
	var alignments : Array
	var equipment_types : Array
	var slot_types : Array
	var slot_defaults : Dictionary
	var vanilla_equipment_defaults_for_reference : Dictionary

	var file:File = File.new()
	
	
	var pointers
	
	func _init(d):
		pointers = d
		
		vanilla_equipment = pointers.DataFormat.__get_script_constant_map_without_load("res://HevLib/scenes/equipment/vanilla_defaults/equipment.gd")
		hardpoint_types = vanilla_data.hardpoint_types.duplicate(true)
		alignments = vanilla_data.alignments.duplicate(true)
		equipment_types = vanilla_data.equipment_types.duplicate(true)
		slot_types = vanilla_data.slot_types.duplicate(true)
		slot_defaults = vanilla_data.slot_defaults.duplicate(true)
		vanilla_equipment_defaults_for_reference = vanilla_data.vanilla_equipment_defaults_for_reference.duplicate(true)
	
	var version : Array = [1,0,0]
	
	func __make_upgrades_scene():
		var SCENE_HEADER = "[gd_scene load_steps=4 format=2]\n\n[ext_resource path=\"res://enceladus/Upgrades.tscn\" type=\"PackedScene\" id=1]\n[ext_resource path=\"res://HevLib/scenes/equipment/hardpoints/WeaponSlotUpgradeTemplate.tscn\" type=\"PackedScene\" id=2]\n[ext_resource path=\"res://enceladus/SystemShipUpgradeUI.tscn\" type=\"PackedScene\" id=3]\n\n[sub_resource type=\"ViewportTexture\" id=1]\nflags = 5\nviewport_path = NodePath(\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP/Contain1/Viewport\")\n\n[sub_resource type=\"ViewportTexture\" id=2]\nviewport_path = NodePath(\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP/Contain2/Control\")\n\n[node name=\"Upgrades\" instance=ExtResource( 1 )]\n\n[node name=\"TextureRect\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP\"]\ntexture = SubResource( 1 )\n\n[node name=\"ControlTexture\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP\"]\ntexture = SubResource( 2 )\n\n[node name=\"TextureRect2\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_MANUAL/Sims\"]\ntexture = SubResource( 1 )\n\n[node name=\"ControlTexture2\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_MANUAL/Sims\"]\ntexture = SubResource( 2 )"
		
		pointers.FolderAccess.__recursive_delete("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/")
		pointers.FolderAccess.__recursive_delete("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/")
		pointers.FolderAccess.__recursive_delete("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/")
		pointers.FolderAccess.__recursive_delete("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/")
		
		# FILE PATHS
		var FILE_PATHS : Array = [
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/Upgrades.tscn",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/Exhaust_Cache",
			
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFY_TEMPLATES.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFY_STANDALONE.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/slot_order.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_SHIP_TEMPLATES.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_SHIP_STANDALONE.json",
			"user://cache/.HevLib_Cache/MenuDriver/save_buttons.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/processed_storage_mods.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/node_definitions.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/ship_node_register.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/AuxSlot.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot_additions.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot_modifications.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFIED_NAMES.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/Slot_Limits.tscn",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/ship_node_modify.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/ship_thruster_colors.json",
			"user://cache/.HevLib_Cache/ShipDriver/",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/Driver_Store.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/slot_order_relative.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/modify_ship_numerics.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/namer.json",
			"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/processed_storage_systems.json",
			
		]
		
		var file_save_path : String = FILE_PATHS[0]
		var exhaust_cache_path : String = FILE_PATHS[1]
		var weaponslot_modify_templates_file : String  = FILE_PATHS[2]
		var weaponslot_modify_standalone_file : String  = FILE_PATHS[3]
		var slot_order_cache_file : String  = FILE_PATHS[4]
		var weaponslot_ship_templates_file : String  = FILE_PATHS[5]
		var weaponslot_ship_standalone_file : String  = FILE_PATHS[6]
		var save_menu_file : String  = FILE_PATHS[7]
		var processed_storage_file : String  = FILE_PATHS[8]
		var node_definitions_file : String  = FILE_PATHS[9]
		var ship_node_register_file : String  = FILE_PATHS[10]
		var auxslot_data_path : String  = FILE_PATHS[11]
		var weaponslot_additions : String  = FILE_PATHS[12]
		var weaponslot_modifications : String  = FILE_PATHS[13]
		var weaponslot_modify_equipment_names : String  = FILE_PATHS[14]
		var upgrades_slot_limits : String  = FILE_PATHS[15]
		var ship_node_modify_file : String  = FILE_PATHS[16]
		var ship_thruster_color_file : String  = FILE_PATHS[17]
		var ship_driver_path : String  = FILE_PATHS[18]
		var storage_for_driver_store : String  = FILE_PATHS[19]
		var slot_order_relative_store : String  = FILE_PATHS[20]
		var modify_ship_numerics_store : String  = FILE_PATHS[21]
		var namer_store : String  = FILE_PATHS[22]
		var processed_storage_systems_file : String  = FILE_PATHS[23]
		
		version = pointers.DataFormat.__get_vanilla_version()
		pointers.l("observed game version of %s" % str(version),"pointers.Equipment")
		var UpgradeMenu : Node = load("res://enceladus/Upgrades.tscn").instance()
		var nodes_parent:Node = UpgradeMenu.get_node("VB/MarginContainer/ScrollContainer/MarginContainer/Items")
		var vanilla_slot_names : Array = []
		var vanilla_slot_types : Dictionary = {}
		
		
		pointers.FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/ship_data/")

		
		for slot in nodes_parent.get_children():
			var children : Array = slot.get_node("VBoxContainer").get_children()
			if children.size() <= 1:
				continue
			vanilla_slot_names.append(slot.name)
			var sys_slot : String  = slot.slot
			var index:int = 1
			if sys_slot == "":
				while not sys_slot:
					sys_slot = children[index].slot
					index += 1
			vanilla_slot_types.merge({slot.name:sys_slot})
		
		
		var ws_equipment_names : Array = []
		
		for item in FILE_PATHS:
			pointers.FolderAccess.__check_folder_exists(item.split(item.split("/")[item.split("/").size() - 1])[0])
		
		var ws_default_templates : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load("res://HevLib/scenes/weaponslot/data_storage/templates.gd") #load("res://HevLib/scenes/weaponslot/data_storage/templates.gd").get_script_constant_map()
		var ws_ship_templates : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load("res://HevLib/scenes/weaponslot/data_storage/ship_templates.gd") #load("res://HevLib/scenes/weaponslot/data_storage/ship_templates.gd").get_script_constant_map()
		var ws_ship_templates_2 : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load("res://HevLib/scenes/weaponslot/data_storage/ship_templates_2.gd") #load("res://HevLib/scenes/weaponslot/data_storage/ship_templates_2.gd").get_script_constant_map()
		var ship_register : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load("res://HevLib/scenes/equipment/ShipModificationDriver/ship_register_vanilla.gd") #load("res://HevLib/scenes/equipment/ShipModificationDriver/ship_register_vanilla.gd").get_script_constant_map()
		var register_default_ships : Array = []
		for item in ship_register:
			register_default_ships.append(ship_register[item])
		
		file.open(weaponslot_modify_templates_file,File.WRITE)
		file.store_string(JSON.print(ws_default_templates.get("TEMPLATES",{})))
		file.close()
		file.open(weaponslot_modify_standalone_file,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(weaponslot_ship_standalone_file,File.WRITE)
		file.store_string(JSON.print(ws_ship_templates.get("SHIP_MODIFY",{})))
		file.close()
		file.open(weaponslot_ship_templates_file,File.WRITE)
		file.store_string(JSON.print(ws_ship_templates_2.get("SHIP_TEMPLATES",{})))
		file.close()
		file.open(slot_order_cache_file,File.WRITE)
		file.store_string("[]")
		file.close()
		file.open(save_menu_file,File.WRITE)
		file.store_string("[]")
		file.close()
		file.open(processed_storage_file,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(processed_storage_systems_file,File.WRITE)
		file.store_string("[]")
		file.close()
		file.open(node_definitions_file,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(ship_thruster_color_file,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(auxslot_data_path,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(weaponslot_modify_equipment_names,File.WRITE)
		file.store_string("[]")
		file.close()
		file.open(ship_node_register_file,File.WRITE)
		file.store_string(JSON.print(register_default_ships))
		file.close()
		file.open(ship_node_modify_file,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(weaponslot_additions,File.WRITE)
		file.store_string("[]")
		file.close()
		file.open(weaponslot_modifications,File.WRITE)
		file.store_string("[]")
		file.close()
		file.open(storage_for_driver_store,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(slot_order_relative_store,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(modify_ship_numerics_store,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(namer_store,File.WRITE)
		file.store_string("{\"crew\":[],\"ships\":[]}")
		file.close()
		
		
		
		var current_mod_ids : Array = pointers.ManifestV2.__get_mod_ids()
		
		var drivers : Array = []
		var mods : Dictionary = pointers.ManifestV2.__get_mod_data()["mods"]
		for md in mods:
			var mod = mods[md]
			if mod.drivers:
				drivers.append(mod.drivers.duplicate(true))
		mods.clear()
		
		var driver_store : Dictionary = {
			"ADD_EQUIPMENT_ITEMS":[],
			"ADD_EQUIPMENT_SLOTS":[],
			"EQUIPMENT_TAGS":[],
			"SLOT_ORDER":[],
			"SLOT_TAGS":[],
			"AUX_POWER_AND_THRUSTERS":[],
			"MODIFY_INTERNALS":{},
			"NODE_DEFINITIONS":[],
			"SHIP_NODE_REGISTER":[],
			"SHIP_NODE_MODIFY":{},
			"SHIP_THRUSTER_COLORS":{},
			"WEAPONSLOT_ADD":[],
			"WEAPONSLOT_MODIFY_TEMPLATES":[],
			"WEAPONSLOT_MODIFY":[],
			"WEAPONSLOT_SHIP_TEMPLATES":{},
			"WEAPONSLOT_SHIP_MODIFY":{},
			"SAVE_BUTTONS":[],
			"ADD_SHIPS":[],
			"REGISTER_SHIP_NUMERICS":{},
			"SLOT_ORDER_RELATIVE":{},
			
		}
		
		var nodemodify_system_name_registers : Array = []
		
		var wsmtpls : Dictionary = ws_default_templates.get("TEMPLATES",{})
		for i in wsmtpls:
			var d = wsmtpls[i].duplicate(true)
			driver_store["WEAPONSLOT_MODIFY_TEMPLATES"].append({i:d})
		
		
		
		for cvh in drivers:
			for last_bit in cvh:
				var constants : Dictionary = cvh[last_bit]
				match last_bit:
					"ADD_EQUIPMENT_ITEMS.gd":
						var arr2 : Array = []
						for item in constants:
							var equipment = constants.get(item).duplicate(true)
							if pointers.ConfigDriver.__validate_dictionary(equipment,false):
								match equipment.get("slot_type","HARDPOINT"):
									"HARDPOINT":
										if "weapon_slot" in equipment:
											var obj : Dictionary = equipment.get("weapon_slot").duplicate(true)
											var wname : String  = equipment.get("system","")
											var wprice:int = equipment.get("price",0)
											var objdata : Array = obj.get("data",[])
											var has_price:bool = false
											var has_invis:bool = false
											var price_string : String  = str(wprice)
											if not "name" in obj:
												obj.merge({"name":wname})
											for d in objdata:
												if d.get("property","") == "repairReplacementPrice":
													d["value"] = price_string
													has_price = true
												if d.get("property","") == "visible":
													has_invis = true
											if not has_price:
												objdata.append({"property":"repairReplacementPrice","value":price_string})
											if not has_invis:
												objdata.append({"property":"visible","value":"false"})
											obj["data"] = objdata.duplicate(true)
											driver_store["WEAPONSLOT_ADD"].append(obj)
										if "WEAPONSLOT_ADD" in equipment:
											var obj : Dictionary = equipment.get("WEAPONSLOT_ADD").duplicate(true)
											var wname : String  = equipment.get("system","")
											var wprice:int = equipment.get("price",0)
											var objdata : Array = obj.get("data",[])
											var has_price:bool = false
											var has_invis:bool = false
											var price_string : String  = str(wprice)
											if not "name" in obj:
												obj.merge({"name":wname})
											for d in objdata:
												if d.get("property","") == "repairReplacementPrice":
													d["value"] = price_string
													has_price = true
												if d.get("property","") == "visible":
													has_invis = true
											if not has_price:
												objdata.append({"property":"repairReplacementPrice","value":price_string})
											if not has_invis:
												objdata.append({"property":"visible","value":"false"})
											obj["data"] = objdata.duplicate(true)
											driver_store["WEAPONSLOT_ADD"].append(obj)
									"MASS_DRIVER_AMMUNITION":
										if "REGISTER_AMMO" in equipment:
											if not "REGISTER_AMMO" in driver_store["REGISTER_SHIP_NUMERICS"]:
												driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_AMMO"] = []
											var bp : Dictionary = equipment["REGISTER_AMMO"].duplicate(true)
											if not "price" in bp:
												bp["price"] = equipment["price"]
											var dc : Dictionary = {equipment.get("num_val",0):bp}
											driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_AMMO"].append(dc)
									"NANODRONE_STORAGE":
										if "REGISTER_NANO" in equipment:
											if not "REGISTER_NANO" in driver_store["REGISTER_SHIP_NUMERICS"]:
												driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_NANO"] = []
											var bp : Dictionary = equipment["REGISTER_NANO"].duplicate(true)
											if not "price" in bp:
												bp["price"] = equipment["price"]
											var dc : Dictionary = {equipment.get("num_val",0):bp}
											driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_NANO"].append(dc)
									"STANDARD_REACTION_CONTROL_THRUSTERS":
										if "AUX_POWER_SLOT" in equipment:
											var bp : Dictionary = equipment["AUX_POWER_SLOT"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
										if "THRUSTERS" in equipment:
											var bp : Dictionary = equipment["THRUSTERS"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
										if "AUX_POWER_AND_THRUSTERS" in equipment:
											var bp : Dictionary = equipment["AUX_POWER_AND_THRUSTERS"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
									"STANDARD_MAIN_ENGINE":
										if "AUX_POWER_SLOT" in equipment:
											var bp : Dictionary = equipment["AUX_POWER_SLOT"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
										if "THRUSTERS" in equipment:
											var bp : Dictionary = equipment["THRUSTERS"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
										if "AUX_POWER_AND_THRUSTERS" in equipment:
											var bp : Dictionary = equipment["AUX_POWER_AND_THRUSTERS"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
									"FISSION_RODS":
										if "REGISTER_REACTOR_RODS" in equipment:
											if not "REGISTER_REACTOR_RODS" in driver_store["REGISTER_SHIP_NUMERICS"]:
												driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_REACTOR_RODS"] = []
											var bp : Dictionary = equipment["REGISTER_REACTOR_RODS"].duplicate(true)
											if not "price" in bp:
												bp["price"] = equipment["price"]
											var dc : Dictionary = {equipment.get("num_val",0):bp}
											driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_REACTOR_RODS"].append(dc)
									"ULTRACAPACITOR":
										if "REGISTER_ULTRACAPACITORS" in equipment:
											if not "REGISTER_ULTRACAPACITORS" in driver_store["REGISTER_SHIP_NUMERICS"]:
												driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_ULTRACAPACITORS"] = []
											var bp : Dictionary = equipment["REGISTER_ULTRACAPACITORS"].duplicate(true)
											if not "price" in bp:
												bp["price"] = equipment["price"]
											var dc : Dictionary = {equipment.get("num_val",0):bp}
											driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_ULTRACAPACITORS"].append(dc)
									"FISSION_TURBINE":
										if "REGISTER_TURBINES" in equipment:
											if not "REGISTER_TURBINES" in driver_store["REGISTER_SHIP_NUMERICS"]:
												driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_TURBINES"] = []
											var bp : Dictionary = equipment["REGISTER_TURBINES"].duplicate(true)
											if not "price" in bp:
												bp["price"] = equipment["price"]
											var dc : Dictionary = {equipment.get("num_val",0):bp}
											driver_store["REGISTER_SHIP_NUMERICS"]["REGISTER_TURBINES"].append(dc)
									"AUX_POWER_SLOT":
										if "auxiliary_power_unit" in equipment:
											var bp : Dictionary = equipment["auxiliary_power_unit"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
										if "AUX_POWER_SLOT" in equipment:
											var bp : Dictionary = equipment["AUX_POWER_SLOT"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
										if "THRUSTERS" in equipment:
											var bp : Dictionary = equipment["THRUSTERS"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
										if "AUX_POWER_AND_THRUSTERS" in equipment:
											var bp : Dictionary = equipment["AUX_POWER_AND_THRUSTERS"].duplicate(true)
											if not "system" in bp:
												bp["system"] = equipment["system"]
											if not "price" in bp:
												bp["price"] = equipment["price"]
											driver_store["AUX_POWER_AND_THRUSTERS"].append(bp)
								
								driver_store["ADD_EQUIPMENT_ITEMS"].append(equipment.duplicate(true))
					"ADD_EQUIPMENT_SLOTS.gd":
						var arr2 : Array = []
						for item in constants:
							var equipment = constants.get(item).duplicate(true)
							if pointers.ConfigDriver.__validate_dictionary(equipment,false):
								driver_store["ADD_EQUIPMENT_SLOTS"].append(equipment.duplicate(true))
					"EQUIPMENT_TAGS.gd":
						var ar : Dictionary = constants.get("EQUIPMENT_TAGS",{}).duplicate(true)
						driver_store["EQUIPMENT_TAGS"].append(ar.duplicate(true))
					"SLOT_ORDER.gd":
						file.open(slot_order_cache_file,File.READ)
						var data : Array = JSON.parse(file.get_as_text()).result
						file.close()
						var orders : Array = constants.get("SLOT_ORDER",[])
						for order in orders:
							if order in data:
								pass
							else:
								data.append(order)
							if not order in driver_store["SLOT_ORDER"]:
								driver_store["SLOT_ORDER"].append(order)
						file.open(slot_order_cache_file,File.WRITE)
						file.store_string(JSON.print(data))
						file.close()
						
						file.open(slot_order_relative_store,File.READ)
						var data2 : Dictionary = JSON.parse(file.get_as_text()).result
						file.close()
						var orders2 : Dictionary = constants.get("SLOT_ORDER_RELATIVE",{})
						for order in orders2:
							if not order in data2:
								data2[order] = orders2[order]
						file.open(slot_order_relative_store,File.WRITE)
						file.store_string(JSON.print(data2))
						file.close()
						
					"SLOT_TAGS.gd":
						var ar : Dictionary = constants.get("SLOT_TAGS",{}).duplicate(true)
						driver_store["SLOT_TAGS"].append(ar.duplicate(true))


					"AUX_POWER_SLOT.gd","THRUSTERS.gd","AUX_POWER_AND_THRUSTERS.gd":
						var arr2 : Array = []
						for item in constants:
							var equipment : Dictionary = constants.get(item).duplicate(true)
							
							if pointers.ConfigDriver.__validate_dictionary(equipment,false):
								driver_store["AUX_POWER_AND_THRUSTERS"].append(equipment.duplicate(true))

					"MODIFY_INTERNALS.gd":
						if "MODIFY_INTERNALS" in constants:
							var pdata : Array = constants.MODIFY_INTERNALS
							
							file.open(processed_storage_file,File.READ)
							var pfdata : Dictionary = JSON.parse(file.get_as_text()).result
							file.close()
							file.open(processed_storage_systems_file,File.READ)
							var sysNames : Array = JSON.parse(file.get_as_text()).result
							file.close()
							for item in pdata:
								var listingSystemName : String  = item.get("system","SYSTEM_MISSING_NAME")
								if not listingSystemName in sysNames:
									sysNames.append(listingSystemName)
								if not listingSystemName in pfdata:
									pfdata[listingSystemName] = {}
								var ls : Dictionary = pfdata[listingSystemName]
								
								ls["minimum_ammo_utilization_for_reduction"] = item.get("minimum_ammo_utilization_for_reduction",ls.get("minimum_ammo_utilization_for_reduction",0.0))
								ls["minimum_nano_utilization_for_reduction"] = item.get("minimum_nano_utilization_for_reduction",ls.get("minimum_nano_utilization_for_reduction",0.0))
								ls["minimum_propellant_utilization_for_reduction"] = item.get("minimum_propellant_utilization_for_reduction",ls.get("minimum_propellant_utilization_for_reduction",0.0))
								
								
								for data in item:
									match data:
										"emp_shielding","nano_speed_add","ammo_speed_add","mass_per_tonne_storage_added","mass_per_tonne_total_storage_added","storage_flat","crew_morale","mass","mass_per_crew_member","mass_per_tonne_of_processed_ore":
											ls[data] = item[data] + ls.get(data,0.0)
										"storage_ammo","storage_ammunition":
											ls["storage_ammo"] = item[data] + ls.get("storage_ammo",0.0)
										"storage_nano","storage_nanodrones":
											ls["storage_nano"] = item[data] + ls.get("storage_nano",0.0)
										"storage_propellant","storage_prop":
											ls["storage_propellant"] = item[data] + ls.get("storage_propellant",0.0)
										"force_type":
											ls["force_type"] = item["force_type"]
										"crew_count":
											ls[data] = item[data] + ls.get(data,0)
										"display_system":
											if not "display_system" in ls:
												ls["display_system"] = {
													"name":"",
													"can_display_multiple":false,
													"power":0.0,
													"status":100.0,
													"affect_inspection":false
												}
											var val : Dictionary = item["display_system"]
											if "name" in val:
												ls["display_system"]["name"] = val.get("name","")
											if "can_display_multiple" in val:
												ls["display_system"]["can_display_multiple"] = val.get("can_display_multiple",false)
											if "status" in val:
												ls["display_system"]["status"] = val.get("status",100.0)
											if "power" in val:
												ls["display_system"]["power"] = val.get("power",0.0)
											if "affect_inspection" in val:
												ls["display_system"]["affect_inspection"] = val.get("affect_inspection",false)
								if "storage_multi_upper" in item or "storage_multi_lower" in item:
									ls["storage_multi"] = float(item.get("storage_multi_upper",1.0))/float(item.get("storage_multi_lower",1.0)) * ls.get("storage_multi",1.0)
								if "ammo_multi_upper" in item or "ammo_multi_lower" in item:
									ls["ammo_multi"] = float(item.get("ammo_multi_upper",1.0))/float(item.get("ammo_multi_lower",1.0)) * ls.get("ammo_multi",1.0)
								if "nano_multi_upper" in item or "nano_multi_lower" in item:
									ls["nano_multi"] = float(item.get("nano_multi_upper",1.0))/float(item.get("nano_multi_lower",1.0)) * ls.get("nano_multi",1.0)
								if "propellant_multi_upper" in item or "propellant_multi_lower" in item:
									ls["propellant_multi"] = float(item.get("propellant_multi_upper",1.0))/float(item.get("propellant_multi_lower",1.0)) * ls.get("propellant_multi",1.0)
								if "mass_multi_upper" in item or "mass_multi_lower" in item:
									ls["mass_multi"] = float(item.get("mass_multi_upper",1.0))/float(item.get("mass_multi_lower",1.0)) * ls.get("mass_multi",1.0)
								if "ammo_speed_multi_upper" in item or "ammo_speed_multi_lower" in item:
									ls["ammo_speed_multi"] = float(item.get("ammo_speed_multi_upper",1.0))/float(item.get("ammo_speed_multi_lower",1.0)) * ls.get("ammo_speed_multi",1.0)
								if "nano_speed_multi_upper" in item or "nano_speed_multi_lower" in item:
									ls["nano_speed_multi"] = float(item.get("nano_speed_multi_upper",1.0))/float(item.get("nano_speed_multi_lower",1.0)) * ls.get("nano_speed_multi",1.0)
								if "emp_scale_multi_upper" in item or "emp_scale_multi_lower" in item:
									ls["emp_scale_multi"] = float(item.get("emp_scale_multi_upper",1.0))/float(item.get("emp_scale_multi_lower",1.0)) * ls.get("emp_scale_multi",1.0)
								
								driver_store["MODIFY_INTERNALS"][listingSystemName] = ls.duplicate(true)
							file.open(processed_storage_file,File.WRITE)
							file.store_string(JSON.print(pfdata))
							file.close()
							file.open(processed_storage_systems_file,File.WRITE)
							file.store_string(JSON.print(sysNames))
							file.close()
					"NODE_DEFINITIONS.gd":
						file.open(node_definitions_file,File.READ)
						var pfdata : Dictionary = JSON.parse(file.get_as_text()).result
						file.close()
						for item in constants:
							var xd : Dictionary = {item:constants.get(item)}
							pfdata.merge(xd)
							driver_store["NODE_DEFINITIONS"].append(xd.duplicate(true))
							
						file.open(node_definitions_file,File.WRITE)
						file.store_string(JSON.print(pfdata))
						file.close()
					"SHIP_NODE_REGISTER.gd":
						file.open(ship_node_register_file,File.READ)
						var pfdata : Array = JSON.parse(file.get_as_text()).result
						file.close()
						for item in constants:
							var xd = constants.get(item)
							pfdata.append(xd)
							driver_store["SHIP_NODE_REGISTER"].append(xd.duplicate(true))
							
						file.open(ship_node_register_file,File.WRITE)
						file.store_string(JSON.print(pfdata))
						file.close()
					"SHIP_NODE_MODIFY.gd":
						file.open(ship_node_modify_file,File.READ)
						var pfdata : Dictionary = JSON.parse(file.get_as_text()).result
						file.close()
						for item in constants:
							var ship : String  = constants[item].get("ship_name","")
							if ship != "":
								if not ship in pfdata:
									pfdata[ship] = []
								if not ship in driver_store["SHIP_NODE_MODIFY"]:
									driver_store["SHIP_NODE_MODIFY"][ship] = []
								for modification in constants[item].get("modifications",[]):
									pfdata[ship].append(modification)
									driver_store["SHIP_NODE_MODIFY"][ship].append(modification.duplicate(true))
						
						file.open(ship_node_modify_file,File.WRITE)
						file.store_string(JSON.print(pfdata))
						file.close()
					"SHIP_THRUSTER_COLORS.gd":
						var cd : Dictionary = constants.get("SHIP_THRUSTER_COLORS",{})
						if cd.size() > 0:
							file.open(ship_thruster_color_file,File.READ)
							var current : Dictionary = JSON.parse(file.get_as_text()).result
							file.close()
							for ship in cd:
								if not ship in driver_store["SHIP_THRUSTER_COLORS"]:
									driver_store["SHIP_THRUSTER_COLORS"][ship] = []
								if not ship in current:
									current.merge({ship:{"node":{},"type":{}}})
								driver_store["SHIP_THRUSTER_COLORS"][ship].append(cd[ship].duplicate(true))
								if "type" in cd[ship]:
									current[ship]["type"].merge(cd[ship]["type"],true)
								if "node" in cd[ship]:
									current[ship]["node"].merge(cd[ship]["node"],true)
								if "recurse_to_variants" in cd[ship]:
									current[ship]["recurse_to_variants"] = cd[ship]["recurse_to_variants"]
								if "config" in cd[ship]:
									current[ship]["config"] = cd[ship]["config"]
								
							file.open(ship_thruster_color_file,File.WRITE)
							file.store_string(JSON.print(current))
							file.close()

					"WEAPONSLOT_ADD.gd":
						var arr2 : Array = []
						for item in constants:
							var equipment : Dictionary = constants.get(item).duplicate(true)
							var n : String = equipment.get("name","")
							if n:
								if not n in ws_equipment_names:
									ws_equipment_names.append(n)
								if pointers.ConfigDriver.__validate_dictionary(equipment,false):
									driver_store["WEAPONSLOT_ADD"].append(equipment.duplicate(true))
					"WEAPONSLOT_MODIFY_TEMPLATES.gd":
						var ar : Dictionary = constants.get("WEAPONSLOT_MODIFY_TEMPLATES",{}).duplicate(true)
						file.open(weaponslot_modify_templates_file,File.READ)
						var founddata : Dictionary = JSON.parse(file.get_as_text(true)).result
						file.close()
						for template in ar:
							if template in founddata.keys():
								for datapoint in ar[template]:
									match datapoint:
										"equipment":
											for item in ar[template][datapoint]:
												if not item in ws_equipment_names:
													ws_equipment_names.append(item)
												if item in founddata[template][datapoint]:
													pass
												else:
													founddata[template][datapoint].append(item)
										"data":
											var data_formatted : Dictionary = {}
											for item in ar[template][datapoint]:
												data_formatted.merge({item.get("property"):item.get("value")})
											for key in data_formatted.keys():
												var is_in_dict:bool = false
												for lps in founddata[template][datapoint]:
													if lps.get("property") == key:
														is_in_dict = true
														lps["value"] = data_formatted[key]
												if not is_in_dict:
													founddata[template][datapoint].append({"property":key,"value":data_formatted.get(key)})
							else:
								founddata[template] = ar.get(template).duplicate(true)
						for i in ar:
							var d = ar[i].duplicate(true)
							driver_store["WEAPONSLOT_MODIFY_TEMPLATES"].append({i:d})
						file.open(weaponslot_modify_templates_file,File.WRITE)
						file.store_string(JSON.print(founddata))
						file.close()
					"WEAPONSLOT_MODIFY.gd":
						var ar = constants.get("WEAPONSLOT_MODIFY",{}).duplicate(true)
						file.open(weaponslot_modify_standalone_file,File.READ)
						var founddata : Dictionary = JSON.parse(file.get_as_text(true)).result
						file.close()
						for item in ar:
							if not item in ws_equipment_names:
								ws_equipment_names.append(item)
							if item in founddata:
								var new_dict : Dictionary = {}
								for c in ar.get(item):
									var prop : String = c.get("property","")
									var val : String = c.get("value","")
									if prop and val:
										new_dict.merge({prop:val})
								var old_dict : Dictionary = {}
								var current_item_data : Dictionary = founddata.get(item)
								for c in current_item_data:
									var prop : String = c.get("property","")
									var val : String = c.get("value","")
									if prop and val:
										old_dict.merge({prop:val})
								for op in new_dict:
									old_dict[op] = new_dict[op]
								var processed : Array = []
								for u in old_dict:
									processed.append({"property":u,"value":old_dict.get(u)})
								founddata.merge({item:processed},true)
							else:
								founddata.merge({item:ar.get(item)})
							driver_store["WEAPONSLOT_MODIFY"].append({item:ar.get(item).duplicate(true)})
						
						file.open(weaponslot_modify_standalone_file,File.WRITE)
						file.store_string(JSON.print(founddata))
						file.close()
					"WEAPONSLOT_SHIP_TEMPLATES.gd":
						var ar : Dictionary = constants.get("WEAPONSLOT_SHIP_TEMPLATES",{}).duplicate(true)
						file.open(weaponslot_ship_templates_file,File.READ)
						var founddata : Dictionary = JSON.parse(file.get_as_text(true)).result
						file.close()
						for ship in ar:
							if not ship in driver_store["WEAPONSLOT_SHIP_TEMPLATES"]:
								driver_store["WEAPONSLOT_SHIP_TEMPLATES"][ship] = []
							driver_store["WEAPONSLOT_SHIP_TEMPLATES"][ship].append({ship:ar[ship].duplicate(true)})
							if ship in founddata.keys():
								var shipdata : Dictionary = ar.get(ship)
								for slot in shipdata:
									if slot in founddata[ship]:
										var compile : Dictionary = {}
										var current_dict : Dictionary = {}
										var new_dict : Dictionary = {}
										for type in founddata[ship][slot]:
											compile.merge({type:[]},true)
											current_dict.merge({type:{}},true)
											for equip in founddata[ship][slot][type]:
												current_dict[type].merge({equip.get("property"):equip.get("value")})
										for type in shipdata[slot]:
											compile.merge({type:[]},true)
											new_dict.merge({type:{}},true)
											for equip in shipdata[slot][type]:
												new_dict[type].merge({equip.get("property"):equip.get("value")})
										current_dict.merge(new_dict,true)
										for item in current_dict:
											for equip in current_dict[item]:
												compile[item].append({"property":equip,"value":current_dict[item].get(equip)})
										founddata[ship][slot] = compile.duplicate(true)
									else:
										founddata[ship][slot] = shipdata.get(slot).duplicate(true)
							else:
								founddata.merge(ar)
						file.open(weaponslot_ship_templates_file,File.WRITE)
						file.store_string(JSON.print(founddata))
						file.close()
					"WEAPONSLOT_SHIP_MODIFY.gd":
						var ar = constants.get("WEAPONSLOT_SHIP_MODIFY",{}).duplicate(true)
						file.open(weaponslot_ship_standalone_file,File.READ)
						var founddata : Dictionary = JSON.parse(file.get_as_text(true)).result
						file.close()
						for ship in ar:
							if not ship in driver_store["WEAPONSLOT_SHIP_MODIFY"]:
								driver_store["WEAPONSLOT_SHIP_MODIFY"][ship] = []
							driver_store["WEAPONSLOT_SHIP_MODIFY"][ship].append({ship:ar[ship].duplicate(true)})
							var slots : Dictionary = ar[ship]
							for slot in slots:
								var equipment = slots[slot]
								for item in equipment:
									if not item in ws_equipment_names:
										ws_equipment_names.append(item)
							
							if ship in founddata:
								var shipdata : Dictionary = ar.get(ship)
								for slot in shipdata:
									if slot in founddata[ship]:
										var compile : Dictionary = {}
										var current_dict : Dictionary = {}
										var new_dict : Dictionary = {}
										for type in founddata[ship][slot]:
											compile.merge({type:[]},true)
											current_dict.merge({type:{}},true)
											for equip in founddata[ship][slot][type]:
												current_dict[type].merge({equip.get("property"):equip.get("value")})
										for type in shipdata[slot]:
											compile.merge({type:[]},true)
											new_dict.merge({type:{}},true)
											for equip in shipdata[slot][type]:
												new_dict[type].merge({equip.get("property"):equip.get("value")})
										current_dict.merge(new_dict,true)
										for item in current_dict:
											for equip in current_dict[item]:
												compile[item].append({"property":equip,"value":current_dict[item].get(equip)})
										founddata[ship][slot] = compile.duplicate(true)
									else:
										founddata[ship][slot] = shipdata.get(slot).duplicate(true)
							else:
								founddata.merge(ar)
						file.open(weaponslot_ship_standalone_file,File.WRITE)
						file.store_string(JSON.print(founddata))
						file.close()
					"SAVE_BUTTONS.gd":
						var ar : Array = constants.get("SAVE_BUTTONS",[]).duplicate(true)
						file.open(save_menu_file,File.READ)
						var founddata : Array = JSON.parse(file.get_as_text(true)).result
						file.close()
						for button in ar:
							founddata.append(button)
							driver_store["SAVE_BUTTONS"].append(button.duplicate(true))
						
						file.open(save_menu_file,File.WRITE)
						file.store_string(JSON.print(founddata))
						file.close()
					"ADD_SHIPS.gd":
						for ar in constants:
							var ac : Dictionary = constants[ar]
							driver_store["ADD_SHIPS"].append(ac.duplicate(true))
					"REGISTER_SHIP_NUMERICS.gd":
						for ar in constants:
							if not ar in driver_store["REGISTER_SHIP_NUMERICS"]:
								driver_store["REGISTER_SHIP_NUMERICS"][ar] = []
							var ac = constants[ar]
							for v in ac:
								driver_store["REGISTER_SHIP_NUMERICS"][ar].append({v:ac[v].duplicate(true)})
					"MODIFY_SHIP_NUMERICS.gd":
						file.open(modify_ship_numerics_store,File.READ)
						var pfdata : Dictionary = JSON.parse(file.get_as_text()).result
						file.close()
						for item in constants:
							var di : Dictionary = constants[item]
							var ship : String  = di.get("ship_name","")
							if ship != "":
								if not ship in pfdata:
									pfdata[ship] = []
								pfdata[ship].append(di)
						file.open(modify_ship_numerics_store,File.WRITE)
						file.store_string(JSON.print(pfdata))
						file.close()
					"NAMER.gd":
						file.open(namer_store,File.READ)
						var pfdata : Dictionary = JSON.parse(file.get_as_text()).result
						file.close()
						if "CREW" in constants:
							var d : Array = constants["CREW"]
							pfdata["crew"].append_array(d)
						
						if "SHIPS" in constants:
							var d : Array = constants["SHIPS"]
							pfdata["ships"].append_array(d)
						
						file.open(namer_store,File.WRITE)
						file.store_string(JSON.print(pfdata))
						file.close()
					
					
		
		file.open(ship_driver_path + "driver_data.json",File.WRITE)
		file.store_string(JSON.print(driver_store["ADD_SHIPS"]))
		file.close()
		
		file.open(ship_driver_path + "register_data.json",File.WRITE)
		file.store_string(JSON.print(driver_store["REGISTER_SHIP_NUMERICS"]))
		file.close()
		
		file.open(storage_for_driver_store,File.WRITE)
		file.store_string(JSON.print(driver_store))
		file.close()
		
		file.open(weaponslot_modify_equipment_names,File.WRITE)
		file.store_string(JSON.print(ws_equipment_names))
		file.close()
		
		var all_slot_node_names : Array = []
		all_slot_node_names.append_array(vanilla_slot_names)
		var slots_for_adding : Array = []
		var slots_for_adding_dict : Dictionary = {}
		var tag_modifications : Array = []
		
		var ship_limitations : Dictionary = {}
		var ship_limitation_string : String  = ""
		
		var equipment_for_adding : Array = []
		
		for nodes in driver_store["EQUIPMENT_TAGS"]:
			if nodes:
				var slotTypes : Array = nodes.get("slot_types",[])
				var equipmentItems : Array = nodes.get("equipment_types",[])
				var align : Array = nodes.get("alignments",[])
				var hardpointTypes : Array = nodes.get("hardpoint_types",[])
				var slotDefaults : Dictionary = nodes.get("slot_defaults",{})
				if slotTypes:
					for st in slotTypes:
						if not st in slot_types:
							slot_types.append(st)
				if equipmentItems.size() > 0:
					for st in equipmentItems:
						if not st in equipment_types:
							equipment_types.append(st)
				if align:
					for st in align:
						if not st in alignments:
							alignments.append(st)
				if hardpointTypes:
					for st in hardpointTypes:
						if not st in hardpoint_types:
							hardpoint_types.append(st)
				if slotDefaults:
					for st in slotDefaults:
						if st in slot_defaults:
							for item in slotDefaults.get(st):
								if not item in slot_defaults.get(st):
									slot_defaults[st].append(item)
						else:
							slot_defaults.merge({st:slotDefaults.get(st)})
		for slotDict in driver_store["ADD_EQUIPMENT_SLOTS"]:
			var snn : String  = slotDict.get("slot_node_name","")
			var spp : Dictionary = ship_limitations.get(snn,{})
			if "limit_ships" in slotDict:
				var val : Array = slotDict["limit_ships"].duplicate()
				if snn in ship_limitations:
					if "limit_ships" in spp:
						for i in val:
							if not i in spp:
								ship_limitations[snn]["limit_ships"] = i
					else:
						ship_limitations[snn]["limit_ships"] = spp["limit_ships"]
				else:
					ship_limitations.merge({snn:{}})
					ship_limitations[snn]["limit_ships"] = val
			if "prevent_ships" in slotDict:
				var val : Array = slotDict["prevent_ships"].duplicate()
				if snn in ship_limitations:
					if "prevent_ships" in spp:
						for i in val:
							if not i in spp:
								ship_limitations[snn]["prevent_ships"] = i
					else:
						ship_limitations[snn]["prevent_ships"] = spp["prevent_ships"]
				else:
					ship_limitations.merge({snn:{}})
					ship_limitations[snn]["prevent_ships"] = val
			slots_for_adding.append(slotDict)
			slots_for_adding_dict.merge({slotDict.get("slot_node_name",""):slotDict})
			all_slot_node_names.append(slotDict.get("slot_node_name",""))
		for node in driver_store["SLOT_TAGS"]:
			if node:
				tag_modifications.append(node)
				for snn in node:
					var data : Dictionary = node[snn]
					var spp : Dictionary = ship_limitations.get(snn,{})
					if "limit_ships" in data:
						var val : Array = data["limit_ships"].duplicate()
						if snn in ship_limitations:
							if "limit_ships" in spp:
								for f in val:
									if not f in spp:
										ship_limitations[snn]["limit_ships"] = f
							else:
								ship_limitations[snn]["limit_ships"] = spp["limit_ships"]
						else:
							ship_limitations.merge({snn:{}})
							ship_limitations[snn]["limit_ships"] = val.duplicate()
					if "prevent_ships" in data:
						var val : Array = data["prevent_ships"].duplicate()
						if snn in ship_limitations:
							if "prevent_ships" in spp:
								for f in val:
									if not f in spp:
										ship_limitations[snn]["prevent_ships"] = f
							else:
								ship_limitations[snn]["prevent_ships"] = spp["prevent_ships"]
						else:
							ship_limitations.merge({snn:{}})
							ship_limitations[snn]["prevent_ships"] = val.duplicate()
		for ns in driver_store["ADD_EQUIPMENT_ITEMS"]:
			if ns:
				equipment_for_adding.append(ns)
		
		var slots_full : Array = []
		var slots_format : PoolStringArray = []
		var editable_paths : PoolStringArray = []
		
		var slot_eligibility : Array = []
		
		var equipment : PoolStringArray = []
		
		var slot_allowed_equipment : Dictionary = {}
		
		for slot in slots_for_adding:
			var m : String  = slot.get("slot_node_name","")
			var format : Dictionary = __make_slot_for_scene(slot)
			
			# FUTURE ME: Write a mod that tag modifies a modded slot, need to double check functionality of this code + define types
			for data in tag_modifications:
				if m in data:
					for check in format:
						if check.keys()[0] == m:
							var slot_override_additive = check[m][2]["override_additive"]
							var slot_override_subtractive = check[m][2]["override_subtractive"]
							var override_additive = data[m].get("override_additive",[])
							var override_subtractive = data[m].get("override_subtractive",[])
							for over in override_additive:
								if not over in slot_override_additive:
									slot_override_additive.append(over)
							for over in override_subtractive:
								if not over in slot_override_subtractive:
									slot_override_subtractive.append(over)
							slot_eligibility.append({m:[[],slot_override_additive,slot_override_subtractive]})
			slots_format.append(format.get(m)[0])
			editable_paths.append(format.get(m)[1])
			slots_full.append(format)
		for slot in vanilla_equipment_defaults_for_reference:
			var vslot_data : Dictionary = vanilla_equipment_defaults_for_reference[slot]
			var vslot_additives : Array = vslot_data.get("override_additive",[])
			var vslot_subtractives : Array = vslot_data.get("override_subtractive",[])
			for dict in tag_modifications:
				if slot in dict:
					var tag_data : Dictionary = dict[slot]
					var tag_add : Array = tag_data.get("override_additive",[])
					var tag_sub : Array = tag_data.get("override_subtractive",[])
					if vslot_additives != []:
						for add in tag_add:
							if not add in vslot_additives:
								vslot_additives.append(add)
					else:
						vslot_additives = tag_add.duplicate()
					if vslot_subtractives != []:
						for sub in tag_sub:
							if not sub in vslot_subtractives:
								vslot_subtractives.append(sub)
					else:
						vslot_subtractives = tag_sub.duplicate()
			if vslot_additives != []:
				vslot_data["override_additive"] = vslot_additives
			if vslot_subtractives != []:
				vslot_data["override_subtractive"] = vslot_subtractives
			vanilla_equipment_defaults_for_reference[slot] = vslot_data
			
			
		for slot in all_slot_node_names:
			if slot in vanilla_equipment_defaults_for_reference:
				var data : Dictionary = vanilla_equipment_defaults_for_reference[slot]
				var slot_type : String  = data.get("slot_type","HARDPOINT").to_upper()
				if slot_type == "HARDPOINT":
					var hardpoint : String  = data.get("hardpoint_type", "")
					var yk : Array = slot_defaults.get(hardpoint,[]).duplicate(true)
					var items : Array = yk.duplicate(true)
					var additives : Array = data.get("override_additive",[])
					var subtractives : Array = data.get("override_subtractive",[])
					for item in additives:
						if not item in items:
							items.append(item)
					for item in subtractives:
						var tmp : Array = []
						for i in items:
							if not i in subtractives:
								tmp.append(i)
						items = tmp.duplicate(true)
					
					slot_allowed_equipment.merge({slot:items})
				else:
					var items : Array = slot_defaults.get(slot_type,[])
					var additives : Array = data.get("override_additive",[])
					var subtractives : Array = data.get("override_subtractive",[])
					for item in additives:
						if not item in items:
							items.append(item)
					for item in subtractives:
						var tmp : Array = []
						for i in items:
							if not i in subtractives:
								tmp.append(i)
						items = tmp.duplicate(true)
					slot_allowed_equipment.merge({slot:items})
			elif slot in slots_for_adding_dict.keys():
				var data : Dictionary = slots_for_adding_dict[slot]
				var slot_type : String  = data.get("slot_type","HARDPOINT").to_upper()
				if slot_type == "HARDPOINT":
					var hardpoint : String  = data.get("hardpoint_type", "")
					var yk : Array = slot_defaults.get(hardpoint,[]).duplicate(true)
					var items : Array = yk.duplicate(true)
					var additives : Array = data.get("override_additive",[])
					var subtractives : Array = data.get("override_subtractive",[])
					for item in additives:
						if not item in items:
							items.append(item)
					for item in subtractives:
						var tmp : Array = []
						for i in items:
							if not i in subtractives:
								tmp.append(i)
						items = tmp.duplicate(true)
					
					slot_allowed_equipment.merge({slot:items})
				else:
					var items : Array = slot_defaults.get(slot_type,[])
					slot_allowed_equipment.merge({slot:items})
			
			
		var equipment_format : PoolStringArray = []
		
		for slot in slots_for_adding:
			if slot.get("add_vanilla_equipment",true):
				for equip in vanilla_equipment:
					var item : Dictionary = vanilla_equipment[equip]
					var allowed_equipment : Array = slot_allowed_equipment.get(slot.get("slot_node_name",""),[]).duplicate(true)
					
					var does:bool = confirm_equipment(vanilla_equipment[equip], slot.get("slot_type",""), slot.get("alignment",""), slot.get("restriction",""), allowed_equipment)
					if does:
						var system_slot : String  = slot.get("system_slot","")
						var string : String  = __make_equipment_for_scene(item, slot.get("slot_node_name",""), system_slot)
						if system_slot == "":
							pass
						equipment_format.append(string)
		for slot in all_slot_node_names:
			if slot in slot_allowed_equipment:
				for item in equipment_for_adding:
					var allowed_equipment : Array = slot_allowed_equipment.get(slot,[]).duplicate(true)
					var slot_type : String  = ""
					var alignment : String  = ""
					var restriction : String  = ""
					var system_slot : String  = ""
					if slot in vanilla_equipment_defaults_for_reference.keys():
						slot_type = vanilla_equipment_defaults_for_reference[slot].get("slot_type","")
						alignment = vanilla_equipment_defaults_for_reference[slot].get("alignment","")
						restriction = vanilla_equipment_defaults_for_reference[slot].get("restriction","")
						system_slot = vanilla_slot_types[slot]
					elif slot in slots_for_adding_dict.keys():
						slot_type = slots_for_adding_dict[slot].get("slot_type","")
						alignment = slots_for_adding_dict[slot].get("alignment","")
						restriction = slots_for_adding_dict[slot].get("restriction","")
						system_slot = slots_for_adding_dict[slot].get("system_slot","")
					var does:bool = confirm_equipment(item, slot_type, alignment, restriction, allowed_equipment)
					if does:
						var string : String  = __make_equipment_for_scene(item, slot, system_slot)
						if system_slot == "":
							pass
						if not string in equipment_format:
							equipment_format.append(string)
			
		var concat : String  = ""
		concat = SCENE_HEADER
		for ref in slots_format:
			concat = concat + "\n\n" + ref
		for equip in equipment_format:
			concat = concat + "\n\n" + equip
		for path in editable_paths:
			concat = concat + "\n\n" + path
		
		
		
		var ws_header : String  = "[gd_scene load_steps=2 format=2]\n\n[ext_resource path=\"res://weapons/WeaponSlot.tscn\" type=\"PackedScene\" id=1]\n\n[node name=\"WeaponSlot\" instance=ExtResource( 1 )]"
		
		var equipment_header : String  = "[node name=\"%s\" parent=\"%s\" instance_placeholder=\"%s\"]"
		var equipment_header_noref : String  = "[node name=\"%s\" parent=\"%s\"]"
		var equipment_editable_path_base : String  = "[editable path=\"%s\"]"
		
		
		var weaponslot_string : String  = ws_header
		var ws_editable_paths : String  = ""
		var weaponslot_properties : Dictionary = {}
		
		var ws_stuff_to_add : Array = []
		var ws_stuff_to_modify : Array = []
		
		for add in driver_store["WEAPONSLOT_ADD"]:
			if pointers.ConfigDriver.__validate_dictionary(add,false):
				var aname : String  = add.get("name","SYSTEM_ERROR")
				var apath : String  = add.get("path","")
				var item_data : Dictionary = {}
				var config : Dictionary = add.get("config",{})
				for it in add.get("data",[]):
					var ws_property_string : String  = ""
					var ws_property : String  = it.get("property")
					var ws_value = it.get("value")
					var split:PoolStringArray = ws_property.split("/")
					var property : String  = split[split.size() - 1]
					if split.size() >= 3:
						var node : String  = split[split.size() - 2]
						var nonode:PoolStringArray = ws_property.split(node)
						if nonode[0].ends_with("/"):
							nonode[0] = nonode[0].rstrip("/")
						if nonode[1].begins_with("/"):
							nonode[1] = nonode[1].lstrip("/")
						if not nonode[0] in item_data:
							item_data.merge({nonode[0]:[]})
						item_data[nonode[0]].append([nonode[1],ws_value])
					elif split.size() == 2:
						if not split[0] in item_data:
							item_data.merge({split[0]:[]})
						item_data[split[0]].append([split[1],ws_value])
					else:
						if not "." in item_data:
							item_data.merge({".":[]})
						item_data["."].append([ws_property,ws_value])
				if apath == "":
					ws_stuff_to_modify.append({"name":aname,"data":item_data})
				else:
					ws_stuff_to_add.append({"name":aname,"path":apath,"data":item_data,"config":config})


			var aname : String = add.get("name","SYSTEM_ERROR")
			var apath : String = add.get("path","")
			var add_header : String = (equipment_header % [aname,".",apath]) if apath else (equipment_header_noref % [aname,"."])
			weaponslot_properties.merge({add_header:[]})
			if ws_editable_paths:
				ws_editable_paths = ws_editable_paths + "\n" + equipment_editable_path_base % aname
			else:
				ws_editable_paths = equipment_editable_path_base % aname
			
			for it in add.get("data",[]):
				var ws_property_string : String  = ""
				var ws_property : String  = it.get("property")
				var ws_value : String  = it.get("value")
				var split:PoolStringArray = ws_property.split("/")
				var property : String  = split[split.size() - 1]
				var parent_path : String  = "."
				if split.size() >= 3:
					var node : String  = split[split.size() - 2]
					var nonode:PoolStringArray = ws_property.split(node)
					if nonode[0].ends_with("/"):
						nonode[0] = nonode[0].rstrip("/")
					if nonode[1].begins_with("/"):
						nonode[1] = nonode[1].lstrip("/")
					var prop_header : String  = equipment_header_noref % [node,aname + "/" + nonode[0]]
					if not prop_header in weaponslot_properties:
						weaponslot_properties.merge({prop_header:[]})
					weaponslot_properties[prop_header].append([nonode[1],ws_value])
				elif split.size() == 2:
					var prop_header : String  = equipment_header_noref % [split[0],aname]
					if not prop_header in weaponslot_properties:
						weaponslot_properties.merge({prop_header:[]})
					weaponslot_properties[prop_header].append([split[1],ws_value])
				else:
					if not add_header in weaponslot_properties:
						weaponslot_properties.merge({add_header:[]})
					weaponslot_properties[add_header].append([ws_property,ws_value])
		
		for property in weaponslot_properties:
			weaponslot_string = weaponslot_string + "\n\n" + property
			var data : Array = weaponslot_properties.get(property)
			for dp in data:
				weaponslot_string = weaponslot_string + "\n" + dp[0] + " = " + dp[1]
		
		file.open(weaponslot_additions,File.WRITE)
		file.store_string(JSON.print(ws_stuff_to_add))
		file.close()
		file.open(weaponslot_modifications,File.WRITE)
		file.store_string(JSON.print(ws_stuff_to_modify))
		file.close()
		
		
		
		for data in driver_store["AUX_POWER_AND_THRUSTERS"]:
			file.open(auxslot_data_path,File.READ)
			var a : Dictionary = JSON.parse(file.get_as_text()).result
			file.close()
			var equipSlots : Array = data.get("slots",[])
			for slot in equipSlots:
				slot = slot.split(".")[0]
				if not slot in a:
					a.merge({slot:[]})
				a[slot].append(data)
			
			file.open(auxslot_data_path,File.WRITE)
			file.store_string(JSON.print(a))
			file.close()
			var aux_path : String  = data.get("path","")
			var aux_type : String  = data.get("type","MPDG").to_upper()
			match aux_type:
				"THRUSTER","RCS","TORCH","MAIN_PROPULSION":
					match aux_type:
						"THRUSTER":
							aux_type = "RCS"
						"MAIN_PROPULSION":
							aux_type = "TORCH"
					if aux_path != "":
						continue
					var sys : String = data.get("system","SYSTEM_NAME_MISSING")
					var auxTypePath : String = exhaust_cache_path + "/" + aux_type
					
					pointers.FolderAccess.__check_folder_exists(auxTypePath)
					
					var exhaust_text : String = make_exhaust_scene(data,sys)
					
					var this_exhaust_path : String = auxTypePath + "/" + sys + "_exhaust.tscn"
					file.open(this_exhaust_path,File.WRITE)
					file.store_string(exhaust_text)
					file.close()
					var exhaust_scn = load(this_exhaust_path).instance()
					var exhaust_pck = PackedScene.new()
					exhaust_pck.pack(exhaust_scn)
					ResourceSaver.save(this_exhaust_path,exhaust_pck)
					exhaust_scn.free()
					
					var thruster_scene : String = make_thruster_scene(data,sys,aux_type,exhaust_cache_path)
					var this_thruster_path : String = auxTypePath + "/" + sys + "_thruster.tscn"
					file.open(this_thruster_path,File.WRITE)
					file.store_string(thruster_scene)
					file.close()
					var thruster_scn = load(this_thruster_path).instance()
					var thruster_pck = PackedScene.new()
					thruster_pck.pack(thruster_scn)
					ResourceSaver.save(this_thruster_path,thruster_pck)
					thruster_scn.free()
		var lim_header : String  = "[gd_scene load_steps=2 format=2]\n\n[ext_resource path=\"res://enceladus/Upgrades.tscn\" type=\"PackedScene\" id=1]\n\n[node name=\"Upgrades\" instance=ExtResource( 1 )]"
		var lim_item : String  = "[node name=\"%s\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items\"]"
		ship_limitation_string = lim_header
		for i in ship_limitations:
			var cc : String = "\n\n" + lim_item % i
			var data : Dictionary = ship_limitations[i]
			if "limit_ships" in data:
				var sl : String = "limit_ships = [ "
				if typeof(data["limit_ships"]) == TYPE_STRING:
					data["limit_ships"] = [data["limit_ships"]]
				for f in range(0,data["limit_ships"].size()):
					if f < data["limit_ships"].size() - 1:
						sl = sl + "\"" + data["limit_ships"][f] + "\", "
					else:
						sl = sl + "\"" + data["limit_ships"][f] + "\" ]"
				cc = cc + "\n" + sl
			if "prevent_ships" in data:
				var sl : String = "prevent_ships = [ "
				if typeof(data["prevent_ships"]) == TYPE_STRING:
					data["prevent_ships"] = [data["prevent_ships"]]
				for f in range(0,data["prevent_ships"].size()):
					if f < data["prevent_ships"].size() - 1:
						sl = sl + "\"" + data["prevent_ships"][f] + "\", "
					else:
						sl = sl + "\"" + data["prevent_ships"][f] + "\" ]"
				cc = cc + "\n" + sl
			ship_limitation_string = ship_limitation_string + cc




		if not ws_editable_paths == "":
			weaponslot_string = weaponslot_string + "\n\n" + ws_editable_paths
		
		file.open(file_save_path,File.WRITE)
		file.store_string(concat)
		file.close()
		
		file.open(upgrades_slot_limits,File.WRITE)
		file.store_string(ship_limitation_string)
		file.close()
		
		UpgradeMenu.free()

	var tagged_vanilla_slots : PoolStringArray = PoolStringArray()

	const SLOT_HEADER = "[node name=\"%s\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items\" instance=ExtResource( 2 )]"
	
	var generated_tex : Dictionary = {}
	
	func create_compiled_tex(texturepath:String, cached_tex_path:String, save_type:String):
		return texturepath
		var filepath : String = ""
		if texturepath in generated_tex:
			filepath = generated_tex[texturepath]
		else:
			filepath = cached_tex_path % save_type
			generated_tex[texturepath] = filepath
			var flareTexture:Texture
			if texturepath.ends_with(".png"):
				flareTexture = pointers.FileAccess.__load_png(texturepath)
			elif texturepath.ends_with(".stex"):
				var st:StreamTexture = StreamTexture.new()
				st.load_path = texturepath
				flareTexture = st
			ResourceSaver.save(filepath,flareTexture)
		
		return filepath
	
	
	func make_thruster_scene(data,sys,aux_type,exhaust_cache_path) -> String:
		var this_sys_path : String = exhaust_cache_path + "/" + aux_type + "/" + sys
		
		var cached_exhaust_path : String = this_sys_path + "_exhaust.tscn"
		var cached_thruster_path : String = this_sys_path + "_thruster.tscn"
		var cached_tex_path : String = this_sys_path + "_texture_%s.res"
		
		var thruster_header : String = "[gd_scene load_steps=2 format=2]\n\n[ext_resource path=\"res://sfx/thruster.tscn\" type=\"PackedScene\" id=1]"
		var nozzle_footer : String = "[editable path=\"nozzle\"]"
		var extra_nozzle_footer : String = "[editable path=\"%s\"]"
		
		var thruster_node_header : String = "\n\n[node name=\"thruster\" instance=ExtResource( 1 )]"
		var this_nozzle_header : String = "\n\n[node name=\"%s\" parent=\".\" index=\"%d\" instance=ExtResource( %d )]"
		var audio_loop_header : String = "\n\n[node name=\"AudioLoop\" parent=\".\" index=\"0\"]"
		var audio_start_header : String = "\n\n[node name=\"AudioStart\" parent=\".\" index=\"1\"]"
		var flare_header : String = "\n\n[node name=\"Flare\" parent=\".\" index=\"2\"]"
		var nozzle_header : String = "\n\n[node name=\"nozzle\" parent=\".\" index=\"%d\"]"
		var base_nozzle_index:int = 3
		
		var ext_path_counter:int = 1
		var ext_path_entry : String = "[ext_resource path=\"%s\" type=\"%s\" id=%d]"
		
		var ext_entries : Array = []
		
		
		var thruster_vars : String = thruster_node_header
		# Base thruster programming
		
		var mass:float = data.get("mass",0)
		thruster_vars += "\n" + "mass = %d" % mass
		var systemName : String = sys
		thruster_vars += "\n" + "systemName = \"%s\"" % systemName
		var priorityOffset:float = data.get("priority_offset",1.0 if aux_type == "RCS" else 8.0)
		thruster_vars += "\n" + "priorityOffset = %f" % priorityOffset
		var mainBrightRatio:float = data.get("main_bright_ratio",0.01)
		thruster_vars += "\n" + "mainBrightRatio = %f" % mainBrightRatio
		var repairReplacementPrice:int = data.get("price",3000 if aux_type == "RCS" else 15000)
		thruster_vars += "\n" + "repairReplacementPrice = %d" % repairReplacementPrice
		var repairReplacementTime:float = data.get("repair_time",1 if aux_type == "RCS" else 4)
		thruster_vars += "\n" + "repairReplacementTime = %d" % repairReplacementTime
		var repairFixPrice:int = data.get("fix_price",500 if aux_type == "RCS" else 1000)
		thruster_vars += "\n" + "repairFixPrice = %d" % repairFixPrice
		var repairFixTime:float = data.get("fix_time",4 if aux_type == "RCS" else 12)
		thruster_vars += "\n" + "repairFixTime = %d" % repairFixTime
		var exhaustEmitOffset:float = data.get("exhaust_emit_offset",8)
		thruster_vars += "\n" + "exhaustEmitOffset = %f" % exhaustEmitOffset
		var scaleOffsetWithPower:bool = data.get("scale_offset_with_power",false)
		thruster_vars += "\n" + "scaleOffsetWithPower = %s" % ("true" if scaleOffsetWithPower else "false")
		var distanceScale:float = data.get("distance_scale",5)
		thruster_vars += "\n" + "distanceScale = %f" % distanceScale
		var plumesFromSettings:bool = data.get("plumes_from_settings",true)
		thruster_vars += "\n" + "plumesFromSettings = %s" % "true" if plumesFromSettings else "false"
		var angularDegreedRange:float = data.get("angular_degree_range",30)
		thruster_vars += "\n" + "angularDegreedRange = %f" % angularDegreedRange
		var rotationRange:float = data.get("rotation_range",PI)
		thruster_vars += "\n" + "rotationRange = %f" % rotationRange
		var consumeCargo:PoolStringArray = data.get("consume_cargo",PoolStringArray())
		var cc : Array = Array(PoolStringArray(consumeCargo))
		thruster_vars += "\n" + "consumeCargo = PoolStringArray(%s)" % (String(cc) if cc.size() else "")
		var canFizzle:bool = data.get("can_fizzle",true)
		thruster_vars += "\n" + "canFizzle = %s" % "true" if canFizzle else "false"
		var wearPowerMaxChance:float = data.get("wear_power_max_chance",0.95)
		thruster_vars += "\n" + "wearPowerMaxChance = %f" % wearPowerMaxChance
		var wearChance:float = data.get("wear_chance",0.01)
		thruster_vars += "\n" + "wearChance = %f" % wearChance
		var accelerationFailLimit:float = data.get("acceleration_fail_limit",400)
		thruster_vars += "\n" + "accelerationFailLimit = %f" % accelerationFailLimit
		var accelerationFailScale:float = data.get("acceleration_fail_scale",200)
		thruster_vars += "\n" + "accelerationFailScale = %f" % accelerationFailScale
		var lightLagChance:float = data.get("light_lag_chance",0.5)
		thruster_vars += "\n" + "lightLagChance = %f" % lightLagChance
		var startJolt:float = data.get("start_jolt",0)
		thruster_vars += "\n" + "startJolt = %f" % startJolt
		var thrust:float = data.get("thrust",1000 if aux_type == "RCS" else 7500)
		thruster_vars += "\n" + "thrust = %f" % thrust
		var command : String = data.get("command","m" if aux_type == "TORCH" else "")
		thruster_vars += "\n" + "command = \"%s\"" % command
		var particleChance:float = data.get("particle_chance",0.5 if aux_type == "RCS" else 1.0)
		thruster_vars += "\n" + "particleChance = %f" % particleChance
		var chokeParticleAdjust:float = data.get("choke_particle_adjust",1)
		thruster_vars += "\n" + "chokeParticleAdjust = %f" % chokeParticleAdjust
		var fadeSeconds:float = data.get("fade_seconds",0.2 if aux_type == "RCS" else 0.4)
		thruster_vars += "\n" + "fadeSeconds = %f" % fadeSeconds
		var windUpSeconds:float = data.get("wind_up_seconds",0.017)
		thruster_vars += "\n" + "windUpSeconds = %f" % windUpSeconds
		var particleScale:float = data.get("particle_scale",5)
		thruster_vars += "\n" + "particleScale = %f" % particleScale
		var randomness:float = data.get("randomness",0.5)
		thruster_vars += "\n" + "randomness = %f" % randomness
		var heatCone:float = data.get("heat_cone",0.5)
		thruster_vars += "\n" + "heatCone = %f" % heatCone
		var minPower:float = data.get("min_power",0.2 if aux_type == "RCS" else 0.8)
		thruster_vars += "\n" + "minPower = %f" % minPower
		var damageWearCapacity:float = data.get("damage_wear_capacity",3600)
		thruster_vars += "\n" + "damageWearCapacity = %f" % damageWearCapacity
		var damageBentCapacity:float = data.get("damage_bent_capacity",3000)
		thruster_vars += "\n" + "damageBentCapacity = %f" % damageBentCapacity
		var damageBentThreshold:float = data.get("damage_bent_threshold",200)
		thruster_vars += "\n" + "damageBentThreshold = %f" % damageBentThreshold
		var damageChokeCapacity:float = data.get("damage_choke_capacity",6000)
		thruster_vars += "\n" + "damageChokeCapacity = %f" % damageChokeCapacity
		var damageChokeThreshold:float = data.get("damage_choke_threshold",400)
		thruster_vars += "\n" + "damageChokeThreshold = %f" % damageChokeThreshold
		var specialFuelLimit:float = data.get("special_fuel_limit",0)
		thruster_vars += "\n" + "specialFuelLimit = %f" % specialFuelLimit
		var heatFireThreshold:float = data.get("heat_fire_threshold",200)
		thruster_vars += "\n" + "heatFireThreshold = %f" % heatFireThreshold
		var heatFireScale:float = data.get("heat_fire_scale",8000)
		thruster_vars += "\n" + "heatFireScale = %f" % heatFireScale
		var heatFireMax:float = data.get("heat_fire_max",0.5)
		thruster_vars += "\n" + "heatFireMax = %f" % heatFireMax
		var maxMissalignment:float = data.get("max_misalignment",0.262 if aux_type == "RCS" else 0.02)
		thruster_vars += "\n" + "maxMissalignment = %f" % maxMissalignment
		var bendWearRatio:float = data.get("bend_wear_ratio",0.025)
		thruster_vars += "\n" + "bendWearRatio = %f" % bendWearRatio
		var specificImpulse:float = data.get("specific_impulse",65 if aux_type == "RCS" else 15)
		thruster_vars += "\n" + "specificImpulse = %f" % specificImpulse
		var thermalFactor:float = data.get("thermal_factor",40)
		thruster_vars += "\n" + "thermalFactor = %f" % thermalFactor
		var powerDraw:float = data.get("power_draw",5000 if aux_type == "RCS" else 100000)
		thruster_vars += "\n" + "powerDraw = %f" % powerDraw
		var gimbalPowerDraw:float = data.get("gimbal_power_draw",100)
		thruster_vars += "\n" + "gimbalPowerDraw = %f" % gimbalPowerDraw
		var thermalHitFactor:float = data.get("thermal_hit_factor",1)
		thruster_vars += "\n" + "thermalHitFactor = %f" % thermalHitFactor
		var inspection:bool = data.get("inspection",true)
		thruster_vars += "\n" + "inspection = %s" % "true" if inspection else "false"
		var gimbal:float = deg2rad(data.get("gimbal",0))
		thruster_vars += "\n" + "gimbal = %f" % gimbal
		var safetyProtocol:bool = data.get("safety_protocol",true)
		thruster_vars += "\n" + "safetyProtocol = %s" % "true" if safetyProtocol else "false"
		var safetyGimbalClear:float = data.get("safety_gimbal_clear",0.419)
		thruster_vars += "\n" + "safetyGimbalClear = %f" % safetyGimbalClear
		var ignitionsPerSecond:float = data.get("ignitions_per_second",10)
		thruster_vars += "\n" + "ignitionsPerSecond = %f" % ignitionsPerSecond
		var gimbalAccurancy:float = data.get("gimbal_accuracy",0.262)
		thruster_vars += "\n" + "gimbalAccurancy = %f" % gimbalAccurancy
		var gimbalPerSecond:float = data.get("gimbal_per_second",3.14)
		thruster_vars += "\n" + "gimbalPerSecond = %f" % gimbalPerSecond
		var gimbalRestAngle:float = data.get("gimbal_rest_angle",0)
		thruster_vars += "\n" + "gimbalRestAngle = %f" % gimbalRestAngle
		var gimbalVectoredThrust:bool = data.get("gimbal_vectored_thrust",false)
		thruster_vars += "\n" + "gimbalVectoredThrust = %s" % ("true" if gimbalVectoredThrust else "false")
		var pulsePerSecond:float = data.get("pulse_per_second",10 if aux_type == "RCS" else 4)
		thruster_vars += "\n" + "pulsePerSecond = %f" % pulsePerSecond
		var pulseEngine:bool = data.get("pulse_engine",true)
		thruster_vars += "\n" + "pulseEngine = %s" % ("true" if pulseEngine else "false")
		var externalPower:bool = data.get("external_power",false)
		thruster_vars += "\n" + "externalPower = %s" % ("true" if externalPower else "false")
		var safetyMaxPower:float = data.get("safety_max_power",1)
		thruster_vars += "\n" + "safetyMaxPower = %f" % safetyMaxPower
		var safetyExtraMargin:float = data.get("safety_extra_margin",1)
		thruster_vars += "\n" + "safetyExtraMargin = %f" % safetyExtraMargin
		var tuneThrustMin:float = data.get("tune_thrust_min",0.5)
		thruster_vars += "\n" + "tuneThrustMin = %f" % tuneThrustMin
		var tuneThrustMax:float = data.get("tune_thrust_max",1.5)
		thruster_vars += "\n" + "tuneThrustMax = %f" % tuneThrustMax
		var sweepHostilityFactor:float = data.get("sweep_hostility_factor",0.2)
		thruster_vars += "\n" + "sweepHostilityFactor = %f" % sweepHostilityFactor
		var damageHostilityScale:int = data.get("damage_hostility_scale",40000000)
		thruster_vars += "\n" + "damageHostilityScale = %f" % damageHostilityScale
		var maxVolume:float = data.get("max_volume",-20)
		thruster_vars += "\n" + "maxVolume = %f" % maxVolume
		var rangeOverride:float = data.get("range_override",0)
		thruster_vars += "\n" + "rangeOverride = %f" % rangeOverride
		var boresightAngleoverride:float = data.get("boresight_angle_override",0)
		thruster_vars += "\n" + "boresightAngleoverride = %f" % boresightAngleoverride
		var pitchOverride:float = data.get("pitch_override",0)
		thruster_vars += "\n" + "pitchOverride = %f" % pitchOverride
		var minChoke:float = data.get("min_choke",0.25)
		thruster_vars += "\n" + "minChoke = %f" % minChoke
		var modulate:Color = Color(data.get("modulate",Color(1,1,1,1)))
		thruster_vars += "\n" + "modulate = Color( %f , %f , %f , %f )" % [modulate.r,modulate.g,modulate.b,modulate.a]
		var self_modulate:Color = Color(data.get("self_modulate",Color(1,1,1,0)))
		thruster_vars += "\n" + "self_modulate = Color( %f , %f , %f , %f )" % [self_modulate.r,self_modulate.g,self_modulate.b,self_modulate.a]
		var offset:Vector2 = Vector2(-32,-16)
		var po = data.get("plume_offset",[-32,-16])
		if (po is Vector2) or (po is Array and po.size() > 1):
			offset[0] = po[0]
			offset[1] = po[1]
		thruster_vars += "\n" + "offset = Vector2( %f , %f )" % [offset.x,offset.y]
		var centered:bool = data.get("plume_centered",false)
		thruster_vars += "\n" + "centered = %s" % ("true" if centered else "false")
		var flip_h:bool = data.get("plume_flip_h",false)
		thruster_vars += "\n" + "flip_h = %s" % ("true" if flip_h else "false")
		var flip_v:bool = data.get("plume_flip_v",false)
		thruster_vars += "\n" + "flip_v = %s" % ("true" if flip_v else "false")
		var hframes:int = data.get("plume_horizontal_frames",8)
		thruster_vars += "\n" + "hframes = %f" % hframes
		var vframes:int = data.get("plume_vertical_frames",1)
		thruster_vars += "\n" + "vframes = %f" % vframes
		var frame:int = data.get("plume_frame",1)
		thruster_vars += "\n" + "frame = %f" % frame
		var frame_coords:Vector2 = Vector2(1,0)
		var plumeFrameCoords = data.get("plume_frame_coords",frame_coords)
		if (plumeFrameCoords is Vector2) or (plumeFrameCoords is Array and plumeFrameCoords.size() > 1):
			frame_coords[0] = plumeFrameCoords[0]
			frame_coords[1] = plumeFrameCoords[1]
		thruster_vars += "\n" + "frame_coords = Vector2( %f , %f )" % [frame_coords.x,frame_coords.y]
		var region_enabled:bool = data.get("plume_region_enabled",false)
		thruster_vars += "\n" + "region_enabled = %s" % ("true" if region_enabled else "false")
		var region_rect:Rect2 = Rect2(0,0,0,0)
		var plRect = data.get("plume_region_rect",Rect2(0,0,0,0))
		if plRect is Array and plRect.size() > 3:
			region_rect = Rect2(plRect[0],plRect[1],plRect[2],plRect[3])
		elif plRect is Rect2:
			region_rect = plRect
		thruster_vars += "\n" + "region_rect = Rect2( %f , %f , %f , %f )" % [region_rect.position.x,region_rect.position.y,region_rect.size.x,region_rect.size.y]
		var region_filter_clip:float = data.get("plume_region_filter_clip",false)
		thruster_vars += "\n" + "region_filter_clip = %s" % ("true" if region_filter_clip else "false")
		var position:Vector2 = Vector2(0,-3)
		var tp = data.get("position",position)
		if tp is Vector2 or (tp is Array and tp.size() > 1):
			position[0] = tp[0]
			position[1] = tp[1]
		thruster_vars += "\n" + "position = Vector2( %f , %f )" % [position.x,position.y]
		var rotation:float = deg2rad(data.get("rotation",0))
		thruster_vars += "\n" + "rotation = %f" % rotation
		var scale:Vector2 = Vector2(0.2,0.2) if aux_type == "RCS" else Vector2(0.939,1.395)
		var ts = data.get("scale",scale)
		if ts is Vector2 or (ts is Array and ts.size() > 1):
			scale[0] = ts[0]
			scale[1] = ts[1]
		thruster_vars += "\n" + "scale = Vector2( %f , %f )" % [scale.x,scale.y]
		
		# Audio loop programming, for when it gets implemented
		var audio_loop_vars : String = audio_loop_header
		
		# Audio start programming, for when it gets implemented
		var audio_start_vars : String = audio_start_header
		
		var flare_vars : String = flare_header
		# Flare programming
		var flare_essentiality:float = data.get("flare_essentiality",0.5 if aux_type == "RCS" else 0.8)
		flare_vars += "\n" + "essentiality = %f" % flare_essentiality
		var flare_offsetByCamera:bool = data.get("flare_offset_by_camera",false)
		flare_vars += "\n" + "offsetByCamera = %s" % ("true" if flare_offsetByCamera else "false")
		var flare_energy:float = data.get("flare_energy",5)
		flare_vars += "\n" + "energy = %f" % flare_energy
		var flare_range_height:float = data.get("flare_range_height",-15)
		flare_vars += "\n" + "range_height = %f" % flare_range_height
		var flare_range_z_min:float = data.get("flare_range_z_min",-4096)
		flare_vars += "\n" + "range_z_min = %f" % flare_range_z_min
		var flare_range_z_max:float = data.get("flare_range_z_max",4096)
		flare_vars += "\n" + "range_z_max = %f" % flare_range_z_max
		var flare_range_layer_min:float = data.get("flare_range_layer_min",-1)
		flare_vars += "\n" + "range_layer_min = %f" % flare_range_layer_min
		var flare_range_layer_max:float = data.get("flare_range_layer_max",1)
		flare_vars += "\n" + "range_layer_max = %f" % flare_range_layer_max
		var flare_offset:Vector2 = Vector2.ZERO
		var fo = data.get("flare_offset",flare_offset)
		if fo is Vector2 or (fo is Array and fo.size() > 1):
			flare_offset[0] = fo[0]
			flare_offset[1] = fo[1]
		flare_vars += "\n" + "offset = Vector2( %f , %f )" % [flare_offset.x,flare_offset.y]
		var flare_texture_scale:float = data.get("flare_texture_scale",6)
		flare_vars += "\n" + "texture_scale = %f" % flare_texture_scale
		var flare_rotation:float = deg2rad(data.get("flare_rotation",0))
		flare_vars += "\n" + "rotation = %f" % flare_rotation
		var flare_position:Vector2 = Vector2.ZERO
		var fp = data.get("flare_position",[0,0])
		if fp is Vector2 or (fp is Array and fp.size() > 1):
			flare_position[0] = fp[0]
			flare_position[1] = fp[1]
		var flare_scale:Vector2 = Vector2(1,1)
		var fs = data.get("flare_scale",[1,1])
		if fs is Vector2 or (fs is Array and fs.size() > 1):
			flare_scale[0] = fs[0]
			flare_scale[1] = fs[1]
		flare_vars += "\n" + "scale = Vector2( %f , %f )" % [flare_scale.x,flare_scale.y]
		var flare_color:Color = Color(data.get("flare_color","3bafff"))
		flare_vars += "\n" + "color = Color( %f , %f , %f , %f )" % [flare_color.r, flare_color.g, flare_color.b, flare_color.a]
		
		
		
		
		
		
		
		
		
		
		
		
		# Exhaust scene
		var exhaust_path : String = "res://sfx/exhaust.tscn"
		match data.get("exhaust_type",""):
			"regular":
				exhaust_path = "res://sfx/exhaust.tscn"
			"fusion":
				exhaust_path = "res://sfx/exhaust-fusion.tscn"
			_:
				if file.file_exists(cached_exhaust_path):
					exhaust_path = cached_exhaust_path
				else:
					exhaust_path = "res://sfx/exhaust.tscn"
		ext_path_counter += 1
		var exhaust_ext : String = ext_path_entry % [exhaust_path,"PackedScene",ext_path_counter]
		ext_entries.append(exhaust_ext)
		thruster_vars += "\n" + "exhaust = ExtResource( %d )" % ext_path_counter
		
		# Material
		var material : String = "res://sfx/AddOnly.material"
		if data.get("plume_has_material",true):
			var matpath : String = data.get("plume_material_path",material)
			if file.file_exists(matpath):
				material = matpath
		else:
			material = ""
		if material:
			ext_path_counter += 1
			var material_ext = ext_path_entry % [material,"Material",ext_path_counter]
			ext_entries.append(material_ext)
			thruster_vars += "\n" + "material = ExtResource( %d )" % ext_path_counter
		else:
			thruster_vars += "\n" + "material = null"
		
		# Plume texture
		var plume_texture : String = "res://sfx/thrusters.png"
		var plumeTex : String = data.get("plume_texture",plume_texture)
		if ResourceLoader.exists(plumeTex):
			plume_texture = plumeTex
		var plumepath : String = create_compiled_tex(plume_texture,cached_tex_path,"plume")
		
		ext_path_counter += 1
		var plume_ext : String = ext_path_entry % [plumepath,"StreamTexture" if plumepath.ends_with(".stex") else "Texture",ext_path_counter]
		ext_entries.append(plume_ext)
		thruster_vars += "\n" + "texture = ExtResource( %d )" % ext_path_counter
		
		# Flare texture
		var flare_texture : String = "res://lights/plume.png"
		var flareTex : String = data.get("flare_texture",flare_texture)
		if ResourceLoader.exists(flareTex):
			flare_texture = flareTex
		var flarepath : String = create_compiled_tex(flare_texture,cached_tex_path,"flare")
		
		ext_path_counter += 1
		var flare_ext : String = ext_path_entry % [flarepath,"StreamTexture" if flarepath.ends_with(".stex") else "Texture",ext_path_counter]
		ext_entries.append(flare_ext)
		flare_vars += "\n" + "texture = ExtResource( %d )" % ext_path_counter
		
		
		# Nozzle handles
		var after_nozzles : Array = []
		var before_nozzles : Array = []
		var nd : Dictionary = convert_to_nozzle(data.get("nozzle",{}))
		for i in data.get("extra_nozzles",[]):
			if i.get("order","after") == "before":
				before_nozzles.append(convert_to_nozzle(i))
			else:
				after_nozzles.append(convert_to_nozzle(i))
		base_nozzle_index += before_nozzles.size()
		var nozzle_groups:PoolStringArray = PoolStringArray()
		var footer_groups:PoolStringArray = PoolStringArray()
		var node_index:int = 2
		
		var nozzle_scene_path : String = "res://ships/modules/nozzle-conventonal.tscn"
		var nozzle_scene_ext:int = 0
		if before_nozzles.size() or after_nozzles.size():
			ext_path_counter += 1
			nozzle_scene_ext = ext_path_counter
			var nozzle_s_ext : String = ext_path_entry % [nozzle_scene_path,"PackedScene",nozzle_scene_ext]
			ext_entries.append(nozzle_s_ext)
		for n in before_nozzles:
			node_index += 1
			var nozzlename : String = "nozzle_%d" % node_index
			var header : String = this_nozzle_header % [nozzlename,node_index,nozzle_scene_ext]
			var nz : Array = format_nozzle(n,header,nozzlename,ext_path_counter,cached_tex_path,ext_path_entry)
			ext_path_counter = nz[1]
			ext_entries.append_array(nz[2])
			nozzle_groups.append(nz[0])
			footer_groups.append(extra_nozzle_footer % [nozzlename])
			
		node_index += 1
		var basenozzlename : String = "nozzle"
		var baseheader : String = nozzle_header % [node_index]
		var basenz : Array = format_nozzle(nd,baseheader,basenozzlename,ext_path_counter,cached_tex_path,ext_path_entry)
		ext_path_counter = basenz[1]
		ext_entries.append_array(basenz[2])
		nozzle_groups.append(basenz[0])
		footer_groups.append(nozzle_footer)
		
		for n in after_nozzles:
			node_index += 1
			var nozzlename : String = "nozzle_%d" % node_index
			var header : String = this_nozzle_header % [nozzlename,node_index,nozzle_scene_ext]
			var nz : Array = format_nozzle(n,header,nozzlename,ext_path_counter,cached_tex_path,ext_path_entry)
			ext_path_counter = nz[1]
			ext_entries.append_array(nz[2])
			nozzle_groups.append(nz[0])
			footer_groups.append(extra_nozzle_footer % [nozzlename])
			
		
		var nodes_to_add:PoolStringArray = PoolStringArray()
		
		# Extra nodes
		var extra_nodes : Array = data.get("extra_nodes",[])
		for node in extra_nodes:
			if ResourceLoader.exists(node):
				var vm = load(node).instance()
				var nodename : String = vm.name
				Tool.remove(vm)
				ext_path_counter += 1
				node_index += 1
				var nodeExt : String = ext_path_entry % [node,"PackedScene",ext_path_counter]
				var nodeId : String = this_nozzle_header % [nodename,node_index,ext_path_counter]
				ext_entries.append(nodeExt)
				nodes_to_add.append(nodeId)
		
		var header_compile : String = thruster_header
		for i in ext_entries:
			header_compile += "\n" + i
		
		var nozzle_compile : String = ""
		for i in nozzle_groups:
			nozzle_compile += "\n" + i
		
		var extra_node_compile : String = ""
		for i in nodes_to_add:
			extra_node_compile += "\n" + i
		
		var footer : String = "\n\n"
		for i in footer_groups:
			footer += "\n" + i
		
		var thruster_text : String = header_compile + thruster_vars + audio_loop_vars + audio_start_vars + flare_vars + nozzle_compile + extra_node_compile + footer
		
		
		return thruster_text
	
	func format_nozzle(nd:Dictionary,header:String,nozzlename:String,current_ext:int,cached_tex_path:String,ext_path_entry:String) -> Array:
		var ext_entries : Array = []
		var nozzle_vars : String = header
		var coolTime:float = nd.cool_time
		var heatTime:float = nd.heat_time
		var texture : String = "res://ships/modules/nozzle-cd.png"
		var normal : String = "res://ships/modules/nozzle-n.png"
		var tx : String = nd.texture
		if ResourceLoader.exists(tx):
			texture = tx
		var nx : String = nd.normal
		if ResourceLoader.exists(nx):
			normal = nx
		var texturepath : String = create_compiled_tex(texture,cached_tex_path,"nozzle_texture")
		
		current_ext += 1
		var sprite_ext : String = ext_path_entry % [texturepath,"StreamTexture" if texturepath.ends_with(".stex") else "Texture",current_ext]
		ext_entries.append(sprite_ext)
		nozzle_vars += "\n" + "texture = ExtResource( %d )" % current_ext
		
		var normalpath : String = create_compiled_tex(normal,cached_tex_path,"nozzle_normal")
		
		current_ext += 1
		var normal_ext : String = ext_path_entry % [normalpath,"StreamTexture" if normalpath.ends_with(".stex") else "Texture",current_ext]
		ext_entries.append(normal_ext)
		nozzle_vars += "\n" + "normal_map = ExtResource( %d )" % current_ext
		
		
		var offset : Array = nd.offset
		nozzle_vars += "\n" + "offset = Vector2( %f , %f )" % [offset[0],offset[1]]
		var centered:bool = nd.centered
		nozzle_vars += "\n" + "centered = %s" % ("true" if centered else "false")
		var flip_h:bool = nd.flip_h
		nozzle_vars += "\n" + "flip_h = %s" % ("true" if flip_h else "false")
		var flip_v:bool = nd.flip_v
		nozzle_vars += "\n" + "flip_v = %s" % ("true" if flip_v else "false")
		var hframes:int = nd.horizontal_frames
		nozzle_vars += "\n" + "hframes = %f" % hframes
		var vframes:int = nd.vertical_frames
		nozzle_vars += "\n" + "vframes = %f" % vframes
		var frame:int = nd.frame
		nozzle_vars += "\n" + "frame = %f" % frame
		var frame_coords : Array = nd.frame_coords
		nozzle_vars += "\n" + "frame_coords = Vector2( %f , %f )" % [frame_coords[0],frame_coords[1]]
		var region_enabled:bool = nd.region_enabled
		nozzle_vars += "\n" + "region_enabled = %s" % ("true" if region_enabled else "false")
		var region_rect : Array = nd.region_rect
		nozzle_vars += "\n" + "region_rect = Rect2( %f , %f , %f , %f )" % [region_rect[0],region_rect[1],region_rect[2],region_rect[3]]
		var region_filter_clip:bool = nd.region_filter_clip
		nozzle_vars += "\n" + "region_filter_clip = %s" % ("true" if region_filter_clip else "false")
		var position : Array = nd.position
		nozzle_vars += "\n" + "position = Vector2( %f , %f )" % [position[0],position[1]]
		var rotation:float = deg2rad(nd.rotation)
		nozzle_vars += "\n" + "rotation = %f" % rotation
		var scale : Array = nd.scale
		nozzle_vars += "\n" + "scale = Vector2( %f , %f )" % [scale[0],scale[1]]
		
		nozzle_vars += "\n\n[node name=\"heat\" parent=\"%s\" index=\"0\"]" % nozzlename
		
		var heat : String = "res://ships/modules/nozzle-cl.png"
		var heat_normal : String = ""
		var hx : String = nd.heat
		if ResourceLoader.exists(hx):
			heat = hx
		var hn : String = nd.heat_normal
		if ResourceLoader.exists(hx):
			heat_normal = hx
		
		var heattexturepath : String = create_compiled_tex(heat,cached_tex_path,"nozzle_heat")
		
		current_ext += 1
		var heat_sprite_ext : String = ext_path_entry % [heattexturepath,"StreamTexture" if heattexturepath.ends_with(".stex") else "Texture",current_ext]
		ext_entries.append(heat_sprite_ext)
		nozzle_vars += "\n" + "texture = ExtResource( %d )" % current_ext
		if heat_normal:
			var heatnormalpath : String = create_compiled_tex(heat_normal,cached_tex_path,"nozzle_heat_normal")
			
			current_ext += 1
			var heatnormal_ext : String = ext_path_entry % [heatnormalpath,"StreamTexture" if heatnormalpath.ends_with(".stex") else "Texture",current_ext]
			ext_entries.append(heatnormal_ext)
			nozzle_vars += "\n" + "normal_map = ExtResource( %d )" % current_ext
		
		
		var heat_offset : Array = nd.offset
		nozzle_vars += "\n" + "offset = Vector2( %f , %f )" % [heat_offset[0],heat_offset[1]]
		var heat_centered:bool = nd.heat_centered
		nozzle_vars += "\n" + "centered = %s" % ("true" if heat_centered else "false")
		var heat_flip_h:bool = nd.heat_flip_h
		nozzle_vars += "\n" + "flip_h = %s" % ("true" if heat_flip_h else "false")
		var heat_flip_v:bool = nd.heat_flip_v
		nozzle_vars += "\n" + "flip_v = %s" % ("true" if heat_flip_v else "false")
		var heat_hframes:int = nd.heat_horizontal_frames
		nozzle_vars += "\n" + "hframes = %f" % heat_hframes
		var heat_vframes:int = nd.heat_vertical_frames
		nozzle_vars += "\n" + "vframes = %f" % heat_vframes
		var heat_frame:int = nd.heat_frame
		nozzle_vars += "\n" + "frame = %f" % heat_frame
		var heat_frame_coords : Array = nd.heat_frame_coords
		nozzle_vars += "\n" + "frame_coords = Vector2( %f , %f )" % [heat_frame_coords[0],heat_frame_coords[1]]
		var heat_region_enabled:bool = nd.heat_region_enabled
		nozzle_vars += "\n" + "region_enabled = %s" % ("true" if heat_region_enabled else "false")
		var heat_region_rect : Array = nd.heat_region_rect
		nozzle_vars += "\n" + "region_rect = Rect2( %f , %f , %f , %f )" % [heat_region_rect[0],heat_region_rect[1],heat_region_rect[2],heat_region_rect[3]]
		var heat_region_filter_clip:bool = nd.heat_region_filter_clip
		nozzle_vars += "\n" + "region_filter_clip = %s" % ("true" if heat_region_filter_clip else "false")
		var heat_position : Array = nd.heat_position
		nozzle_vars += "\n" + "position = Vector2( %f , %f )" % [heat_position[0],heat_position[1]]
		var heat_rotation:float = deg2rad(nd.heat_rotation)
		nozzle_vars += "\n" + "rotation = %f" % heat_rotation
		var heat_scale : Array = nd.heat_scale
		nozzle_vars += "\n" + "scale = Vector2( %f , %f )" % [heat_scale[0],heat_scale[1]]
		
		var out : Array = [nozzle_vars,current_ext,ext_entries]
		return out
	
	const nozzle_template = {
		"cool_time":4,
		"heat_time":0.25,
		"texture":"res://ships/modules/nozzle-cd.png",
		"normal":"res://ships/modules/nozzle-n.png",
		"heat":"res://ships/modules/nozzle-cl.png",
		"heat_normal":"",
		"centered":true,
		"offset":[0,0],
		"flip_h":false,
		"flip_v":false,
		"horizontal_frames":1,
		"vertical_frames":1,
		"frame":0,
		"frame_coords":[0,0],
		"region_enabled":false,
		"region_rect":[0,0,0,0],
		"region_filter_clip":false,
		"position":[0,0],
		"rotation":0,
		"scale":[1,1],
		"heat_centered":true,
		"heat_offset":[0,0],
		"heat_flip_h":false,
		"heat_flip_v":false,
		"heat_horizontal_frames":1,
		"heat_vertical_frames":1,
		"heat_frame":0,
		"heat_frame_coords":[0,0],
		"heat_region_enabled":false,
		"heat_region_rect":[0,0,0,0],
		"heat_region_filter_clip":false,
		"heat_position":[0,0],
		"heat_rotation":0,
		"heat_scale":[1,1],
	}
	
	func convert_to_nozzle(noz):
		var nozzle:Dictionary = nozzle_template.duplicate(true)
		for i in nozzle:
			if i in noz and typeof(nozzle[i]) == typeof(noz[i]):
				nozzle[i] = noz[i]
		return nozzle
	
	
	func make_exhaust_scene(data:Dictionary,sys:String) -> String:
		var exhaust_header : String = "[gd_scene load_steps=3 format=2]\n\n[ext_resource path=\"res://sfx/exhaust.tscn\" type=\"PackedScene\" id=1]\n[ext_resource path=\"%s\" type=\"%s\" id=2]\n\n[sub_resource type=\"CircleShape2D\" id=1]\nradius = %s\n\n[node name=\"exhaust\" instance=ExtResource( 1 )]"
		var exhaust_footer : String = "[node name=\"Sprite\" parent=\".\" index=\"1\"]\ntexture = ExtResource( 2 )"
		
		var light_lag_chance:float = data.get("exhaust_light_lag_chance",0)
		var base_lifetime:float = data.get("exhaust_base_lifetime",0.25)
		var lifetime:float = data.get("exhaust_lifetime",0.25)
		var end_scale:float = data.get("exhaust_end_scale",0.02)
		var self_remove:float = data.get("exhaust_self_remove",0.02)
		var mass:float = data.get("exhaust_mass",0.1)
		var sprite : String = data.get("exhaust_sprite","res://sfx/ball-of-flame.png")
		var sprite_scale : Array = data.get("exhaust_sprite_scale",[0.5,0.5])
		var radius:float = data.get("exhaust_collider_radius",2.87)
		
		var tex_type : String = ""
		if sprite.ends_with(".png"):
			tex_type = "Texture"
		elif sprite.ends_with(".stex"):
			tex_type = "StreamTexture"
		else:
			tex_type = "Texture"
			sprite = "res://sfx/ball-of-flame.png"
		
		var exhaust_text : String = exhaust_header % [sprite,tex_type,str(radius)]
		
		exhaust_text += "\nmass = %s" % mass
		exhaust_text += "\nlightLagChance = %s" % light_lag_chance
		exhaust_text += "\nbaseLifetime = %s" % base_lifetime
		exhaust_text += "\nlifetime = %s" % lifetime
		exhaust_text += "\nendScale = %s" % end_scale
		if self_remove:
			exhaust_text += "\nselfRemove = true"
		else:
			exhaust_text += "\nselfRemove = false"
		
		exhaust_text += "\n\n[node name=\"CollisionShape2D\" parent=\".\" index=\"0\"]\nshape = SubResource( 1 )\n\n" + exhaust_footer
		exhaust_text += "\nscale = Vector2(%s,%s)" % [sprite_scale[0],sprite_scale[1]]
		return exhaust_text

	func confirm_equipment(equipment_node, slot_type, slot_alignment, slot_restriction, slot_allowed_equipment) -> bool:
		var e_slot_type : String = equipment_node.get("slot_type","")
		var e_equipment : String = equipment_node.get("equipment_type","")
		var e_alignment : String = equipment_node.get("alignment","")
		var e_restriction : String = equipment_node.get("restriction","")
		if equipment_node.get("system","") in vanilla_data.min_version:
			var data : Array = vanilla_data.min_version.get(equipment_node.system)
			var failtext : String = "Equipment %s not adding due to old game version. Needed min version: %s ; observed game version: %s" % [str(equipment_node.get("system","")), str(data), str(version)]
			if data[0] < version[0]:
				pass
			elif data[0] == version[0]:
				if data[1] < version[1]:
					pass
				elif data[1] == version[1]:
					if data[2] <= version[2]:
						pass
					else:
						pointers.l(failtext)
						return false
				else:
					pointers.l(failtext)
					return false
			else:
				pointers.l(failtext)
				return false
			
		if e_slot_type == slot_type:
			var passes_slot_check:bool = false
			if e_equipment in slot_allowed_equipment:
				var tp:int = typeof(slot_type)
				if tp == TYPE_STRING:
					if slot_type == "HARDPOINT":
						if slot_alignment in alignments:
							if e_alignment in alignments:
								if e_alignment == slot_alignment:
									passes_slot_check = true
								else:
									return false
							else:
								passes_slot_check = true
						else:
							passes_slot_check = true
					else:
						passes_slot_check = true
				elif tp == TYPE_ARRAY:
					for s in slot_type:
						if s == "HARDPOINT":
							if slot_alignment in alignments:
								if e_alignment in alignments:
									if e_alignment == slot_alignment:
										passes_slot_check = true
									else:
										return false
								else:
									passes_slot_check = true
							else:
								passes_slot_check = true
						
						else:
							passes_slot_check = true
				else:
					passes_slot_check = false
			else:
				return false
			if passes_slot_check:
				if not slot_restriction == "":
					if not e_restriction == "":
						if e_restriction == slot_restriction:
							return true
						else:
							return false
					else:
						return true
				else:
					return true
			else:
				return false
		else:
			return false
		return false
	
	func __make_equipment_for_scene(equipment_data: Dictionary, slot_node_name : String, system_slot: String) -> String:
		var num_val:int = equipment_data.get("num_val", -1)
		var system : String = equipment_data.get("system", "")
		var capability_lock:bool = equipment_data.get("capability_lock", false)
		var name_override : String = equipment_data.get("name_override", "")
		var description : String = equipment_data.get("description", "")
		var manual : String = equipment_data.get("manual", "")
		var specs : String = equipment_data.get("specs", "")
		var price:int = equipment_data.get("price", 0)
		var test_protocol : String = equipment_data.get("test_protocol", "fire")
		var default:bool = equipment_data.get("default", false)
		var control : String = equipment_data.get("control", "")
		var story_flag : String = equipment_data.get("story_flag", "")
		var story_flag_min:int = equipment_data.get("story_flag_min", -1)
		var story_flag_max:int = equipment_data.get("story_flag_max", -1)
		var warn_if_thermal_below:float = equipment_data.get("warn_if_thermal_below", 0)
		var warn_if_electric_below:float = equipment_data.get("warn_if_electric_below", 0)
		var sticker_price_format : String = equipment_data.get("sticker_price_format", "%s E$")
		var sticker_price_multi_format : String = equipment_data.get("sticker_price_multi_format", "%s E$ (x%d)")
		var installed_color:Color = equipment_data.get("installed_color", Color(0.0, 1.0, 0.0, 1.0))
		var disabled_color:Color = equipment_data.get("disabled_color", Color(0.2, 0.2, 0.2, 1.0))
		var slots : Array = equipment_data.get("slots",[])
		var alignment : String = equipment_data.get("alignment","")
		var equipment_type : String = equipment_data.get("equipment_type","")
		var slot_type : String = equipment_data.get("slot_type","")
		var restriction : String = equipment_data.get("restriction","")
		
		var cfg : Dictionary = equipment_data.get("config",{})
		
		var base : String = "[node name=\"%s\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items/%s/VBoxContainer\" instance=ExtResource( 3 )]" % [system.to_upper(),slot_node_name]
		if num_val != -1:
			base = base + "\nnumVal = " + str(num_val)
		base = base + "\nslot = \"" + system_slot + "\""
		if system != "":
			base = base + "\nsystem = \"" + system + "\""
		if capability_lock:
			base = base + "\ncapabilityLock = true"
		else:
			base = base + "\ncapabilityLock = false"
		if name_override != "":
			base = base + "\nnameOverride = \"" + name_override + "\""
		if description != "":
			base = base + "\ndescription = \"" + description + "\""
		if manual != "":
			base = base + "\nmanual = \"" + manual + "\""
		if specs != "":
			base = base + "\nspecs = \"" + specs + "\""
		if price != 0:
			base = base + "\nprice = " + str(price)
		if test_protocol != "":
			base = base + "\ntestProtocol = \"" + test_protocol + "\""
		if default:
			base = base + "\ndefault = true"
		else:
			base = base + "\ndefault = false"
		if control != "":
			base = base + "\ncontrol = \"" + control + "\""
		if story_flag != "":
			base = base + "\nstoryFlag = \"" + story_flag + "\""
		if story_flag_min != -1:
			base = base + "\nstoryFlagMin = " + str(story_flag_min)
		if story_flag_max != -1:
			base = base + "\nstoryFlagMax = " + str(story_flag_max)
		if warn_if_thermal_below != 0:
			base = base + "\nwarnIfThermalBelow = " + str(warn_if_thermal_below)
		if warn_if_electric_below != 0:
			base = base + "\nwarnIfElectricBelow = " + str(warn_if_thermal_below)
		if sticker_price_format != "%s E$":
			base = base + "\nstickerPriceFormat = \"" + sticker_price_format + "\""
		if sticker_price_multi_format != "%s E$ (x%d)":
			base = base + "\nstickerPriceMultiFormat" + sticker_price_multi_format + "\""
		if installed_color != Color(0.0, 1.0, 0.0, 1.0):
			base = base + "\ninstalledColor = " + str(Color(0.0, 1.0, 0.0, 1.0))
		if disabled_color != Color(0.2, 0.2, 0.2, 1.0):
			base = base + "\ndisabledColor = " + str(Color(0.2, 0.2, 0.2, 1.0))
		
		if cfg:
			var cfg_id : String = cfg.get("id","")
			var cfg_section : String = cfg.get("section","")
			var cfg_setting : String = cfg.get("entry","")
			var cfg_invert:bool = cfg.get("invert_config",false)
			base += "\nconfig_id = \"" + cfg_id + "\""
			base += "\nconfig_section = \"" + cfg_section + "\""
			base += "\nconfig_setting = \"" + cfg_setting + "\""
			if cfg_invert:
				base += "\ninvert_config = true"
			else:
				base += "\ninvert_config = false"
		return base
	
	func __make_slot_for_scene(slot_data: Dictionary) -> Dictionary:
		var systemSlot : String = slot_data.get("system_slot", "")
		var slotNodeName : String = slot_data.get("slot_node_name", "MISSING_SLOT_NAME")
		var slotDisplayName : String = slot_data.get("slot_display_name", "SLOT_MISSING_DATA")
		var hasNone:bool = slot_data.get("has_none", true)
		var alwaysDisplay:bool = slot_data.get("always_display", true)
		var restrictType : String = slot_data.get("restrict_type", "")
		var openByDefault:bool = slot_data.get("open_by_default", false)
		var limitShips : Array = slot_data.get("limit_ships", [])
		var preventShips : Array = slot_data.get("prevent_ships", [])
		var add_vanilla_equipment:bool = slot_data.get("add_vanilla_equipment", true)
		var slot_type : String = slot_data.get("slot_type","HARDPOINT")
		var hardpoint_type : String = slot_data.get("hardpoint_type","")
		var alignment : String = slot_data.get("alignment","")
		var restriction : String = slot_data.get("restriction","")
		var override_additive : Array = slot_data.get("override_additive",[])
		var override_subtractive : Array = slot_data.get("override_subtractive",[])
		var restrict_hold_type : String = slot_data.get("restrict_hold_type","")
		
		var cfg : Dictionary = slot_data.get("config",{})
		
		
		var base : String = "[node name=\"%s\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items\" instance=ExtResource( 2 )]" % slotNodeName
		if systemSlot != "":
			base = base + "\nslot = \"" + systemSlot + "\""
		if alwaysDisplay:
			base = base + "\nalways = true"
		else:
			base = base + "\nalways = false"
		if openByDefault:
			base = base + "\nopenByDefault = true"
		else:
			base = base + "\nopenByDefault = false"
		if cfg:
			var cfg_id : String = cfg.get("id","")
			var cfg_section : String = cfg.get("section","")
			var cfg_setting : String = cfg.get("entry","")
			var cfg_invert:bool = cfg.get("invert_config",false)
			base += "\nconfig_id = \"" + cfg_id + "\""
			base += "\nconfig_section = \"" + cfg_section + "\""
			base += "\nconfig_setting = \"" + cfg_setting + "\""
			if cfg_invert:
				base += "\ninvert_config = true"
			else:
				base += "\ninvert_config = false"
			
			
		if restrictType != "":
			base = base + "\nslot = \"" + restrictType + "\""
		if limitShips != []:
			var initial : String = base + "\nlimit_ships = ["
			var one:bool = false
			for item in limitShips:
				if one == false:
					one = true
				else:
					initial = initial + ", "
				initial = initial + "\"" + item + "\""
			initial = initial + "]"
			base = initial
		if preventShips != []:
			var initial : String = base + "\nprevent_ships = ["
			var one:bool = false
			for item in preventShips:
				if one == false:
					one = true
				else:
					initial = initial + ", "
				initial = initial + "\"" + item + "\""
			initial = initial + "]"
			base = initial
		if restrict_hold_type != "":
			base = base + "\nrestrict_hold_type = \"%s\"" % restrict_hold_type
		base = base + "\n\n[node name=\"CheckButton\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items/%s/VBoxContainer/HBoxContainer\"]\ntext = \"%s\"" % [slotNodeName,slotDisplayName]
		
		if hasNone:
			var dta : String = __make_equipment_for_scene({"system":"SYSTEM_NONE","default":true,"name":"None"}, slotNodeName, systemSlot)
			base = base + "\n\n" + dta
		var editable_path : String = "[editable path=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items/%s\"]" % slotNodeName
		
		var dict : Dictionary = {
				"add_vanilla_equipment":add_vanilla_equipment,
				"hardpoint_type":hardpoint_type,
				"alignment":alignment,
				"restriction":restriction,
				"override_additive":override_additive,
				"override_subtractive":override_subtractive,
			}
		
		return {slotNodeName:[base, editable_path, dict]}
	
	
	

class _Events:
	var scripts : Array = [
		load("res://HevLib/events/event_handler.gd"),
		load("res://HevLib/events/clear_event.gd"),
	]
	
	func get_class_documentation():
		return {
			"description":"Contains methods to help spawn or clear events in the ring",
			"methods":{
				"__spawn_event":{
					"description":"Spawns an event in the rings",
					"args":[
						"event -> (String) the event name to be spawned",
						"thering -> TheRing node. Must be present to work.",
						"parameters -> (Dictionary) Any parameters used for spawning events. Defaults to `{}`. Currently supports:",
						"	legacy -> (bool) whether it should use a very old hacky method of hijacking the testSpecificStoryElement property to spawn the event. Has to wait at least 0.1 seconds inbetween spawns. Defaults to `false`",
						"	inject -> (bool) whether the event should be placed directly in the ring, bypassing any event handling methods. Has issues with POI-based events. Defaults to `false`",
						"	x_direction -> (float) horizontal direction which the event will be spawned in. Will be clamped if it exceeds -1 or 1. Defaults to a random range between -1 and 1.",
						"	y_direction -> (float) vertical direction which the event will be spawned in. Will be clamped if it exceeds -1 or 1. Defaults to a random range between -1 and 1.",
						"	spawn_direction_scale -> (float) how much your ship's velocity will be scaled by when calculating the offset added by your velocity. Defaults to 0.75",
						"	oddity_spawn_radius_min -> (int) minimum distance the event will spawn under normal conditions. NOTE: 1 unit represents 100 cm. Defaults to 24000",
						"	oddity_spawn_radius_min_cutscene -> (int) minimum distance the event will spawn while in a cutscene (which only happens during astrogation in the vanilla game to make POI events close to the ship when travelling). NOTE: 1 unit represents 100 cm. Defaults to 6000",
						"	oddity_spawn_radius_max -> (int) maximum distance the event is allowed to spawn at under normal conditions",
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
		}
	
	var pointers
	func _init(p):
		pointers = p
	
	func __spawn_event(event : String, thering, parameters : Dictionary = {}):
		var f = scripts[0].new()
		f.spawn_event(event,thering,parameters)
	
	func __clear_event(event : String,ring,clear_related_poi : bool = true,clear_in_cargo : bool = false):
		var f = scripts[1].new()
		f.clear_event(event,ring,clear_related_poi,clear_in_cargo)
	

class _FileAccess:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"Methods to aide with file interactions",
			"methods":{
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
					"description":"Reads and parses a PNG file during runtime, without the need to precompile to STEX",
					"args":[
						"filepath -> (String) the file path to the PNG file"
					],
					"return":[
						"ImageTexture for the png"
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
			}
		}
	
	var pointers
	func _init(f):
		pointers = f
	
	var dir:Directory = Directory.new()
	var file:File = File.new()
	func __get_file_content(file_path: String) -> String:
		file.open(file_path, File.READ)
		var s : String = file.get_as_text(true)
		file.close()
		return s
	
	
	
	func __copy_file(file_path : String, folder : String):
		var prepfile : String = ProjectSettings.localize_path(file_path)
		var fn : String = prepfile.split("/")[prepfile.split("/").size() - 1]
		return dir.copy(prepfile,folder + "/" + fn)
	
	func __load_png(path) -> Texture:
		file.open(path, File.READ)
		var bytes:PoolByteArray = file.get_buffer(file.get_len())
		var img = Image.new()
		var data = img.load_png_from_buffer(bytes)
		var imgtex = ImageTexture.new()
		imgtex.create_from_image(img)
		file.close()
		return imgtex
	
	var updateCacheDir : String = "user://cache/.Mod_Menu_2_Cache/updates"
	var updateCacheFile : String = updateCacheDir + "/mods_to_update.json"
	var modCacheDir : String = updateCacheDir + "/zip_cache"
	var has_updated_store : String = updateCacheDir + "/has_updated.txt"
	func __precache_mod_file(filepath:String):
		filepath = ProjectSettings.localize_path(filepath)
		pointers.FolderAccess.__check_folder_exists(modCacheDir)
		if file.file_exists(filepath):
			var exists:int = OK
			var modDir : String = filepath.get_base_dir()
			if modDir != modCacheDir:
				exists = __copy_file(filepath,modCacheDir)
				filepath = modCacheDir + filepath.split(modDir)[1]
			var cache : Array = []
			if file.file_exists(updateCacheFile):
				cache = JSON.parse(__get_file_content(updateCacheFile)).result
			if not filepath in cache:
				cache.append(filepath)
			file.open(updateCacheFile,File.WRITE)
			file.store_string(JSON.print(cache))
			file.close()
			if exists == OK:
				file.open(has_updated_store,File.WRITE)
				file.store_string("1")
				file.close()
	
	func __load_precached_mods():
		var gameInstallDirectory = OS.get_executable_path().get_base_dir()
		if OS.get_name() == "OSX":
			gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
		var modPathPrefix = gameInstallDirectory.plus_file("mods")
		if file.file_exists(updateCacheFile):
			var files_to_copy : Array = JSON.parse(__get_file_content(updateCacheFile)).result
			var reboot:int = FAILED
			for mod in files_to_copy:
				if file.file_exists(mod):
					var check:int = __copy_file(mod,modPathPrefix)
					if check == OK:
						reboot = OK
			file.open(updateCacheFile,File.WRITE)
			file.store_string("[]")
			file.close()
			if reboot == OK:
				var path = OS.get_executable_path()
				var args = OS.get_cmdline_args()
				var pid = OS.execute(path, args, false)
				OS.kill(OS.get_process_id())
	
	
	
	
	
	
	
	

class _FolderAccess:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"Methods used to help with directory management",
			"methods":{
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
						"showFolders -> (bool) Whether to display any subdirectories, which will have a forward slash at the end of the name to differentiate them. Defaults to `false`",
						"returnFullPath -> (bool) Whether to show the full directory path of the file/folder, instead of just the name. Defaults to `false`",
						"globalizePath -> (bool) Whether to globalize the path with ProjectSettings.globalize_path() Defaults to `false`"
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
			}
		}
	
	
	var file:File = File.new()
	var directory:Directory = Directory.new()
	func __check_folder_exists(folder: String, status_array: bool = false):
		var value:bool = false
		var exists:bool = false
		if directory.dir_exists(folder):
			value = true
			exists = true
		else:
			exists = false
			value = directory.make_dir_recursive(folder) == OK
		if status_array:
			return [value,exists]
		else:
			return value
	
	func __recursive_delete(path: String) -> bool:
		if not directory.open(path) == OK:
			return false
		if not path.ends_with("/"):
			path = path + "/"
		var filesForDeletion : Array = []
		var foldersForDeletion : Array = []
		var pms : Array = __fetch_folder_files(path, true, true)
		for entry in pms:
			if str(entry).ends_with("/"):
				foldersForDeletion.append(entry)
			else:
				filesForDeletion.append(entry)
		for f in filesForDeletion:
			var splitFiles = str(f).split("/")[str(f).split("/").size()-1]
			directory.open(path)
			directory.remove(splitFiles)
		for folder in foldersForDeletion:
			__recursive_delete(folder)
		directory.open(path)
		directory.remove(path)
		return true
	
	func __fetch_folder_files(folder: String, showFolders: bool = false, returnFullPath: bool = false,globalizePath: bool = false) -> Array:
		var fileList : PoolStringArray = PoolStringArray()
		if not folder.ends_with("/"):
			folder += "/"
		if not directory.dir_exists(folder):
			return []
		directory.open(folder)
		var dirName : String = directory.get_current_dir()
		directory.list_dir_begin(true)
		while true:
			var fileName : String = directory.get_next()
			var capture:bool = true
			if fileName.ends_with("/"):
				capture = false
			if fileName == "." or fileName == "..":
				capture = false
			if capture:
				dirName = directory.get_current_dir()
				if fileName == "":
					break
				if directory.current_is_dir():
					if not showFolders:
						continue
					if not fileName.ends_with("/"):
						fileName = fileName + "/"
				if returnFullPath:
					fileName = folder + fileName
				if globalizePath:
					fileList.append(ProjectSettings.globalize_path(fileName))
				else:
					fileList.append(fileName)
		return Array(fileList)
	
	func __get_first_file(folder: String):
		var firstFile
		var fileNo = 0
		var fileList : Array = __fetch_folder_files(folder)
		for file in fileList:
			if fileNo == 0:
				firstFile = file
				fileNo = 1
		if firstFile == null:
			return ""
		else:
			return firstFile
	
	var folderStructureCache : Dictionary = {}
	
	func __get_folder_structure(folder : String,store_file_content : bool = false, recache : bool = true):
		if (not folder in folderStructureCache) or recache:
			var folder_structure : Dictionary = {}
			var files : Array = __fetch_folder_files(folder,true,false)
			for object in files:
				if object.ends_with("/"):
					var data : Dictionary = __get_folder_structure(folder+object,store_file_content)
					folder_structure.merge({object:data})
				else:
					var fd : String = "FILE"
					if store_file_content:
						file.open(folder + object,File.READ)
						fd = file.get_as_text(true)
						file.close()
					folder_structure.merge({object:fd})
			folderStructureCache[folder] = folder_structure.duplicate(true)
			return folder_structure
		return folderStructureCache[folder].duplicate(true)
	
	

class _Github:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	func _init(p):
		pointers = p
	
	func __get_github_filesystem(URL: String, node_to_return_to: Node, behaviour: String = "normal", special_behaviour_data = ""):
		var rng:RandomNumberGenerator = RandomNumberGenerator.new()
		rng.randomize()
		var CRoot = Tool.get_tree().get_root()
		var gitHubFS := preload("res://HevLib/scenes/fetch_from_github/fs/FetchGithubData.tscn").instance()
		gitHubFS.URL = URL
		gitHubFS.ActOnModData = behaviour
		gitHubFS.mod_version = special_behaviour_data
		gitHubFS.nodeToReturnTo = node_to_return_to
		gitHubFS.name = "git_filesystem_" + str(rng.randi_range(1, 32767))
		CRoot.call_deferred("add_child",gitHubFS)
	
	func __get_github_release(URL: String, folder: String, node_to_return_to: Node, get_pre_releases: bool = false, file_preference: String = "any", file_to_download: String = "first"):
		var cancel:bool = false
		if node_to_return_to == null or (not node_to_return_to is Node):
			cancel = true
			var e : String = "Release Downloader ERROR! Provided node [%s] either does not exist or is not of [Node] type." % str(node_to_return_to)
			pointers.l(e,"pointers.Github")
			printerr(e)
		if not node_to_return_to.has_method("_downloaded_zip"):
			cancel = true
			var e : String = "Release Downloader ERROR! Provided node [%s] does not have the method [_downloaded_zip]" % str(node_to_return_to)
			pointers.l(e,"pointers.Github")
			printerr(e)
		if cancel:
			return
		var CRoot = Tool.get_tree().get_root()
		var gitHubFS := preload("res://HevLib/scenes/fetch_from_github/releases/NetHandles.tscn").instance()
		if not node_to_return_to.has_method("_get_github_progress"):
			gitHubFS.state_progress = false
			pointers.l("Release Downloader NOTICE! Provided node [%s] does not have the method [_get_github_progress]. No download progress will be reported." % str(node_to_return_to),"pointers.Github")
		var rng:RandomNumberGenerator = RandomNumberGenerator.new()
		rng.randomize()
		gitHubFS.releases_URL = URL
		gitHubFS.folder = folder
		gitHubFS.get_pre_releases = get_pre_releases
		gitHubFS.file_preference = file_preference
		gitHubFS.file_to_download = file_to_download
		gitHubFS.nodeToReturnTo = node_to_return_to
		gitHubFS.name = "git_release_" + str(rng.randi_range(1, 32767))
		CRoot.call_deferred("add_child",gitHubFS)
	

class _HevLib:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	func _init(f):
		pointers = f
	
	func __get_lib_variables():
		var varNode = ModLoader.get_node("/root/HevLib~Variables")
		var aData = varNode.AchievementData
		var aPercentData = varNode.AchievementPercentageStats
		return {"AchievementData":aData,"AchievementPercentageStats":aPercentData}
	
	func __get_lib_pointers(return_as_full_path: bool = false) -> Array:
		var path = "res://HevLib/pointers/"
		var files = pointers.FolderAccess.__fetch_folder_files(path)
		if return_as_full_path:
			var compileArray = []
			for f in files:
				compileArray.append(path + f)
			return compileArray
		else:
			return files
	
	func __get_pointer_functions(pointer: String, return_JSON: bool = false) -> Dictionary:
		var path = "res://HevLib/pointers/"
		var pSplit = pointer.split("/")
		var actualPointer = path + pSplit[pSplit.size() - 1]
		var pointerLoad = load(actualPointer).new()
		var pFuncs = pointerLoad.get_method_list()
		var methods = {}
		for pFunc in pFuncs:
			var pFuncName = pFunc.name
			if pFuncName.begins_with("__"):
				var data = pointerLoad.get_property_list()
				var devHint = {}
				for item in data:
					if item.get("name") == "developer_hint":
						devHint = pointerLoad.developer_hint
				var desc = devHint.get(pFuncName, [TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_1"),TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_2")])
				methods.merge({pFuncName:desc})
		if return_JSON:
			var psj = JSON.print(methods, "\t")
			return psj
		else:
			return methods
	
	func __get_library_functionality(return_JSON: bool = false) -> Dictionary:
		var path = "res://HevLib/pointers/"
		var functions = {}
		var files = pointers.FolderAccess.__fetch_folder_files(path)
		for pointer in files:
			var pSplit = pointer.split("/")
			var actualPointer = path + pSplit[pSplit.size() - 1]
			var pl = load(actualPointer)
			var pointerLoad = pl.new()
			var pFuncs = pointerLoad.get_method_list()
			var methods = {}
			for pFunc in pFuncs:
				var pFuncName = pFunc.name
				if pFuncName.begins_with("__"):
					var data = pointerLoad.get_property_list()
					var devHint = {}
					for item in data:
						if item.get("name") == "developer_hint":
							devHint = pointerLoad.developer_hint
					var desc = devHint.get(pFuncName, [TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_1"),TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_2")])
					methods.merge({pFuncName:desc})
			var concat = {pointer:methods}
			functions.merge(concat)
		if return_JSON:
			var psj = JSON.print(functions, "\t")
			return psj
		else:
			return functions
	
	
	
	

class _Keymapping:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	
	func _init(f):
		pointers = f
	
	
	
	var keybind_folder = "user://cache/.HevLib_Cache/Keybinds/"
	var vanilla_binds_file = "user://cfg/Vanilla_Binds.cfg"
	
	var file = File.new()
	
	var overrides = load("res://HevLib/scenes/keymapping/data/overrides.gd").get_script_constant_map()
	
	
	func __load_input_data(key:String, controls: Array,opts:Dictionary):
		file.open(keybind_folder + "defined_control_configs.json",File.READ)
		var current = JSON.parse(file.get_as_text(true)).result
		file.close()
		if not key in current:
			current[key] = {"controls":controls,"opts":opts}

		file.open(keybind_folder + "defined_control_configs.json",File.WRITE)
		file.store_string(JSON.print(current))
		file.close()
		for revis in controls:
			__add_inputs_to_inputmap(key,revis)
	
	func __add_inputs_to_inputmap(key,controls):
		if typeof(controls) == TYPE_STRING:
			controls = [controls]
		if not controls:
			return
		var i = controls[0]
		if i.begins_with("Mouse "):
			var event = InputEventMouseButton.new()
			event.button_index = int(i.split("Mouse ")[1])
			if not InputMap.action_has_event(key,event):
				pointers.l("Adding input event [%s] for [%s]" % [i,key],"pointers.Keymapping")
				InputMap.action_add_event(key, event)
			else:
				pointers.l("Input event [%s] for [%s] already exists, skipping" % [i,key],"pointers.Keymapping")
		elif i.begins_with("JoyButton "):
			var event = InputEventJoypadButton.new()
			event.button_index = int(i.split("JoyButton ")[1])
			if not InputMap.action_has_event(key,event):
				pointers.l("Adding input event [%s] for [%s]" % [i,key],"pointers.Keymapping")
				InputMap.action_add_event(key, event)
			else:
				pointers.l("Input event [%s] for [%s] already exists, skipping" % [i,key],"pointers.Keymapping")
		elif i.begins_with("JoyAxis "):
			var event = InputEventJoypadMotion.new()
			event.axis = abs(int(i.split("JoyAxis ")[1]))
			if i.split("JoyAxis ")[1].begins_with("-"):
				event.axis_value = -1.0
			else:
				event.axis_value = 1.0
			if not InputMap.action_has_event(key,event):
				pointers.l("Adding input event [%s] for [%s]" % [i,key],"pointers.Keymapping")
				InputMap.action_add_event(key, event)
			else:
				pointers.l("Input event [%s] for [%s] already exists, skipping" % [i,key],"pointers.Keymapping")

		else:
			var event = InputEventKey.new()
			event.scancode = OS.find_scancode_from_string(i)
			if not InputMap.action_has_event(key,event):
				pointers.l("Adding input event [%s] for [%s]" % [i,key],"pointers.Keymapping")
				InputMap.action_add_event(key, event)
			else:
				pointers.l("Input event [%s] for [%s] already exists, skipping" % [i,key],"pointers.Keymapping")
	
	var input_cache = {}
	
	func __define_vanilla_binds():
		var recache = input_cache.empty()
		pointers.FolderAccess.__check_folder_exists(keybind_folder)
		var subm = {}
		
		
		if recache:
			for ie in __get_vanilla_action_list():
				subm[ie] = []
				var events = InputMap.get_action_list(ie)
				for event in events:
					var ev = __event_to_string(event)
					if not ev in subm[ie]:
						subm[ie].append(ev)
			input_cache = subm.duplicate(true)
		else:
			subm = input_cache.duplicate(true)
		
		return subm
	
	func __get_formatted_vanilla_binds() -> Dictionary:
		
		var output = {}
		var bound = {}
		var current = {}
		if file.file_exists(vanilla_binds_file):
			current = pointers.ConfigDriver.__config_parse(vanilla_binds_file)
		if file.file_exists("user://settings.cfg"):
			bound = pointers.ConfigDriver.__config_parse("user://settings.cfg").get("input",{})
		var vanilla_binds = __define_vanilla_binds()
		var vopts = overrides["vanilla_bind_opts"]
		var missing = ""
		for ie in vanilla_binds:
			if ie in current:
				pass
				
				output[ie] = current[ie]
				
			else:
				var sect = {"can_be_rebound":false,"inputs":[],"opts":{}}
				var dv = vanilla_binds[ie]
				
				if ie in vopts:
					sect["opts"] = vopts[ie].duplicate(true)
				else:
					missing += "\n\t\"" + ie + "\":{},"
					printerr("HevLib Keymapping: vanilla ActionEvent ",ie," does NOT have defined opt overrides.")
				if ie in bound:
					sect.can_be_rebound = true
				for action in dv:
					if typeof(action) == TYPE_STRING:
						action = [action]
					sect.inputs.append(action)
				output[ie] = sect
		if missing:
			printerr(missing)
		pointers.ConfigDriver.__config_store(output,vanilla_binds_file)
		return output
	
	func __event_to_string(event):
		if event is InputEventKey:
			var key = OS.get_scancode_string(event.physical_scancode) if event.scancode == 0 else OS.get_scancode_string(event.scancode)
			return key
		elif event is InputEventJoypadMotion:
			var v = sign(event.axis_value)
			var a = event.axis * v
			var joyAxisString = "JoyAxis " + str(a)
			return joyAxisString
		elif event is InputEventJoypadButton:
			var joyButtonString = "JoyButton " + str(event.button_index)
			return joyButtonString
		elif event is InputEventMouseButton:
			var mouseString = "Mouse " + str(event.button_index)
			return mouseString
		return ""
	
	func __string_to_scancode(event:String, give_type = false) -> int:
		if give_type:
			var out = [null,null]
			if event.begins_with("JoyAxis "):
				var ac = int(event.split("JoyAxis ")[1])
				var additive = (12000 * sign(ac))
				var joyAxisString = ac + additive
				out[0] = joyAxisString
				out[1] = 3
			elif event.begins_with("JoyButton "):
				var joyButtonString = int(event.split("JoyButton ")[1]) + 11000
				out[0] = joyButtonString
				out[1] = 2
			elif event.begins_with("Mouse "):
				var mouseString = int(event.split("Mouse ")[1]) + 10000
				out[0] = mouseString
				out[1] = 1
			else:
				var key = OS.find_scancode_from_string(event)
				out[0] = key
				out[1] = 0
			return out
		else:
			if event.begins_with("JoyAxis "):
				var raw = event.split("JoyAxis ")[1]
				var ac = int(raw)
				var sn = sign(ac)
				if raw.begins_with("-"):
					sn = -1
				if sn == 0:
					sn = 1
				var additive = (12000 * sn)
				var joyAxisString = ac + additive
				return joyAxisString
			elif event.begins_with("JoyButton "):
				var joyButtonString = int(event.split("JoyButton ")[1]) + 11000
				return joyButtonString
			elif event.begins_with("Mouse "):
				var mouseString = int(event.split("Mouse ")[1]) + 10000
				return mouseString
			else:
				var key = OS.find_scancode_from_string(event)
				return key
	
	
	func __match_event_type(event):
		var eventType = []
		if event is InputEvent:
			eventType.append("InputEvent")
		if event is InputEventAction:
			eventType.append("InputEventAction")
		if event is InputEventGesture:
			eventType.append("InputEventGesture")
		if event is InputEventJoypadButton:
			eventType.append("InputEventJoypadButton")
		if event is InputEventJoypadMotion:
			eventType.append("InputEventJoypadMotion")
		if event is InputEventKey:
			eventType.append("InputEventKey")
		if event is InputEventMIDI:
			eventType.append("InputEventMIDI")
		if event is InputEventMagnifyGesture:
			eventType.append("InputEventMagnifyGesture")
		if event is InputEventMouse:
			eventType.append("InputEventMouse")
		if event is InputEventMouseButton:
			eventType.append("InputEventMouseButton")
		if event is InputEventMouseMotion:
			eventType.append("InputEventMouseMotion")
		if event is InputEventPanGesture:
			eventType.append("InputEventPanGesture")
		if event is InputEventScreenDrag:
			eventType.append("InputEventScreenDrag")
		if event is InputEventScreenTouch:
			eventType.append("InputEventTouch")
		if event is InputEventWithModifiers:
			eventType.append("InputEventWithModifiers")
		return eventType
	
	func __simulate_input_press(action,continuous = true):
		if continuous:
			var ie = InputEventAction.new()
			ie.action = action
			ie.pressed = true
			Input.parse_input_event(ie)
		else:
			Input.action_press(action)
	
	func __simulate_input_depress(action,continuous = true):
		if continuous:
			var ie = InputEventAction.new()
			ie.action = action
			ie.pressed = false
			Input.parse_input_event(ie)
		else:
			Input.action_release(action)
	
	var base_action_list = []
	
	func __get_vanilla_action_list():
		if not base_action_list:
			for setting in ProjectSettings.get_property_list():
				if setting.name.begins_with('input/'):
					base_action_list.append(setting.name.split("/")[1])
		return base_action_list.duplicate(true)
	
	func __get_built_in_action_list():
		return [
			"ui_accept",
			"ui_select",
			"ui_cancel",
			"ui_focus_next",
			"ui_focus_prev",
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down",
			"ui_page_up",
			"ui_page_down",
			"ui_home",
			"ui_end",
		]
	
	func __get_opts_from_key_data(key_data):
#		var activation = key_data.get("activation","press") # can be `press`, `release`, or `both`. Defines when the keybind activates
#		var context = key_data.get("context","in_game") # can be `in_game`, `in_menu`, or `both`. Defines whether the bind works in menus (OMS included) or in game
#		var allow_empty_bind = key_data.get("allow_empty_bind",false) # Defines if an empty keybind is valid (always active)
		var allow_extra_keys = key_data.get("allow_extra_keys",true) # Are additional keys allowed to be held to still activate the keybind
		var order_sensitive = key_data.get("order_sensitive",true) # Defines if the keys have to be pressed in the order they were inputted
		var exclusive = key_data.get("exclusive",false) # If true, then cancels other exclusive actions containing only part of the binds this action uses.
		
		var opts = {
#			"activation":activation,
#			"context":context,
#			"allow_empty_bind":allow_empty_bind,
			"allow_extra_keys":allow_extra_keys,
			"order_sensitive":order_sensitive,
			"exclusive":exclusive
		}
		
		return opts
	
	func __create_input_event(action: String, event: Array,opts:Dictionary):
		for ev in event:
			if opts.order_sensitive:
				var scan = __string_to_scancode(ev[-1],true)
				match scan[1]:
					0:
						var ie = InputEventKey.new()
						var s = scan[0]
						ie.scancode = s
						ie.physical_scancode = s
						InputMap.action_add_event(action,ie)
					1:
						var ie = InputEventMouseButton.new()
						var s = scan[0] - 10000
						ie.button_index = s
						InputMap.action_add_event(action,ie)
					2:
						var ie = InputEventJoypadButton.new()
						var s = scan[0] - 11000
						ie.button_index = s
						InputMap.action_add_event(action,ie)
					3:
						var ie = InputEventJoypadMotion.new()
						var so = scan[0]
						var sig = sign(so)
						var s = 0
						var negoffset = (12000 * sig)
						if sig >= 0:
							sig = 1
							s = so - negoffset
						else:
							s = -so + negoffset
						ie.axis = s
						ie.axis_value = sig
						InputMap.action_add_event(action,ie)
			else:
				var scans = []
				for sc in ev:
					scans.append(__string_to_scancode(sc,true))
				for scan in scans:
					match scan[1]:
						0:
							var ie = InputEventKey.new()
							var s = scan[0]
							ie.scancode = s
							ie.physical_scancode = s
							InputMap.action_add_event(action,ie)
						1:
							var ie = InputEventMouseButton.new()
							var s = scan[0] - 10000
							ie.button_index = s
							InputMap.action_add_event(action,ie)
						2:
							var ie = InputEventJoypadButton.new()
							var s = scan[0] - 11000
							ie.button_index = s
							InputMap.action_add_event(action,ie)
						3:
							var ie = InputEventJoypadMotion.new()
							var so = scan[0]
							var sig = sign(so)
							var s = 0
							var negoffset = (12000 * sig)
							if sig >= 0:
								sig = 1
								s = so - negoffset
							else:
								s = -so + negoffset
							ie.axis = s
							ie.axis_value = sig
							InputMap.action_add_event(action,ie)
#					breakpoint
	
	
	
	
	

class _ManifestV1:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	func _init(d):
		pointers = d
	
	func __load_manifest_from_file(manifest):
		var manifestConfig = {
		"package":{
			"id":null,
			"name":null,
			"version":"unknown",
			"description":"MODMENU_DESCRIPTION_PLACEHOLDER",
			"group":"",
			"github_homepage":"",
			"github_releases":"",
			"discord_thread":"",
			"nexus_page":"",
			"donations_page":"",
			"wiki_page":"",
			"custom_link":"",
			"custom_link_name":"",
			}
		}
		var manifestFile = ConfigFile.new()
		var error = manifestFile.load(manifest)
		if error != OK:
			return
		for section in manifestConfig:
			var currentManifest = Array(manifestFile.get_section_keys(section))
			for key in manifestFile.get_section_keys(section):
				manifestConfig[section][key] = manifestFile.get_value(section, key)
		return manifestConfig
	
	func __load_file(modDir, zipDir, hasManifest, manifestDirectory, hasIcon, iconDir):
		var manifestName = ""
		var manifestId = ""
		var manifestVersion = ""
		var manifestDescription = ""
		var manifestGroup = ""
		var github_homepage = ""
		var github_releases = ""
		var discord_thread = ""
		var nexus_page = ""
		var donations_page = ""
		var wiki_page = ""
		var custom_link = "MODMENU_CUSTOM_LINK_PLACEHOLDER"
		var custom_link_name = "MODMENU_CUSTOM_LINK_NAME_PLACEHOLDER"
		var dirSplit = zipDir.split("/")
		var dirSplitSize = dirSplit.size()
		var fallbackDir = dirSplit[dirSplitSize - 1]
		var parentFolder = str(dirSplit[dirSplitSize - 2])
		var f = File.new()
		if hasManifest and not parentFolder == "disabled_mod_cache":
			f.open(manifestDirectory, File.READ)
			var manifestData = __load_manifest_from_file(manifestDirectory)
			manifestName = manifestData["package"]["name"]
			manifestId = manifestData["package"]["id"]
			manifestVersion = manifestData["package"]["version"]
			manifestDescription = manifestData["package"]["description"]
			manifestGroup = manifestData["package"]["group"]
			github_homepage = manifestData["package"]["github_homepage"]
			github_releases = manifestData["package"]["github_releases"]
			discord_thread = manifestData["package"]["discord_thread"]
			nexus_page = manifestData["package"]["nexus_page"]
			donations_page = manifestData["package"]["donations_page"]
			wiki_page = manifestData["package"]["wiki_page"]
			custom_link = manifestData["package"]["custom_link"]
			custom_link_name = manifestData["package"]["custom_link_name"]
			f.close()
		f.open(modDir, File.READ)
		var modFolderSplit = modDir.split("/ModMain.gd")
		var modFolderCount = modFolderSplit.size()
		var separateModFolderDir = modFolderSplit[modFolderCount - 2].split("/")
		var modFolderSecondCount = separateModFolderDir.size()
		var modFolder = separateModFolderDir[modFolderSecondCount - 1]
		var nameCheck = 0
		var modName = ""
		var prioCheck = 0
		var modPrio = 0
		var modVer = ""
		var verCheck = 0
		var content = f.get_as_text(true)
		var modMainLines = content.split("\n")
		for l in modMainLines:
			if not hasManifest or manifestName == "" or manifestName == null:
				var modNameCheck = l.split("const MOD_NAME = ")
				var modNameCheckSize = modNameCheck.size()
				if modNameCheckSize >= 2:
					var splitName = pointers.DataFormat.__array_to_string(modNameCheck[1].split("\""))
					while splitName.begins_with(" "):
						var beginningSpaceRemover = splitName.split(" ")
						splitName = pointers.DataFormat.__array_to_string(beginningSpaceRemover[1])
					while splitName.ends_with(" "):
						var endSpaceRemover = splitName.split(" ")
						splitName = pointers.DataFormat.__array_to_string(endSpaceRemover[0])
					nameCheck = 1
					modName = splitName
			else:
				nameCheck = 1
				modName = manifestName
			var priorityCheck = l.split("const MOD_PRIORITY = ")
			var priorityCheckSize = priorityCheck.size()
			if priorityCheckSize >= 2:
				prioCheck += 1
				modPrio = priorityCheck[1]
			if not nameCheck == 1:
				modName = fallbackDir
			if not prioCheck == 1:
				modPrio = 0
			var versionCheck = l.split("const MOD_VERSION = ")
			var versionCheckSize = versionCheck.size()
			if not manifestVersion == "":
				verCheck = 1
				modVer = manifestVersion
			elif versionCheckSize >= 2 and not manifestVersion == modVer:
				verCheck = 1
				modVer = versionCheck[1]
			else:
				modVer = "unknown"
		var prioStr = String(modPrio)
		var ver = ""
		if verCheck == 1:
			ver = modVer
		else:
			ver = "unknown"
		var verData = String(ver)
		if manifestDescription == null or manifestDescription == "":
			manifestDescription = "MODMENU_DESCRIPTION_PLACEHOLDER"
		if manifestGroup == null or manifestGroup == "":
			manifestGroup = "MODMENU_GROUP_PLACEHOLDER"
		if manifestId == null or manifestId == "":
			manifestId = "MODMENU_ID_PLACEHOLDER"
		if github_homepage == null or github_homepage == "":
			github_homepage = "MODMENU_GITHUB_HOMEPAGE_PLACEHOLDER"
		if github_releases == null or github_releases == "":
			github_releases = "MODMENU_GITHUB_RELEASES_PLACEHOLDER"
		if discord_thread == null or discord_thread == "":
			discord_thread = "MODMENU_DISCORD_PLACEHOLDER"
		if nexus_page == null or nexus_page == "":
			nexus_page = "MODMENU_NEXUS_PLACEHOLDER"
		if donations_page == null or donations_page == "":
			donations_page = "MODMENU_DONATIONS_PLACEHOLDER"
		if wiki_page == null or wiki_page == "":
			wiki_page = "MODMENU_WIKI_PLACEHOLDER"
		if custom_link == null or custom_link == "":
			custom_link = "MODMENU_CUSTOM_LINK_PLACEHOLDER"
		if custom_link_name == null or custom_link_name == "":
			custom_link_name = "MODMENU_CUSTOM_LINK_NAME_PLACEHOLDER"
		if hasIcon:
			iconDir = iconDir
		else:
			iconDir = "empty"
		var compiledData = modName + "\n" + fallbackDir + "\n" + prioStr + "\n" + modFolder + "\n" + verData + "\n" + manifestDescription + "\n" + github_homepage + "\n" + github_releases + "\n" + discord_thread + "\n" + nexus_page + "\n" + donations_page + "\n" + wiki_page + "\n" + custom_link + "\n" + custom_link_name + "\n" + iconDir + "\n" + manifestId
		return compiledData
	
	func __get_mod_main(file, split_into_array = false):
		var hasManifest = false
		var manifestDir = ""
		var hasIcon = false
		var pngDir = ""
		var stexDir = ""
		var iconDir = ""
		var modData
		var modMainPath = ""
		var filesInZip = pointers.Zip.__get_zip_content(file)
		for m in filesInZip:
			var modPath = "res://" + m
			m = m.split(m.split("/")[0] + "/")[1].to_lower()
			if m.begins_with("mod") and m.ends_with(".manifest"):
				hasManifest = true
				manifestDir = modPath
			if m.begins_with("icon"):
				if m.ends_with(".png"):
					hasIcon = true
					pngDir = modPath
				if m.ends_with(".stex"):
					hasIcon = true
					stexDir = modPath
			if m.begins_with("modmain") and m.ends_with(".gd"):
				modMainPath = modPath
		if stexDir:
			iconDir = stexDir
		elif pngDir:
			iconDir = pngDir
		modData = __load_file(modMainPath, file, hasManifest, manifestDir, hasIcon, iconDir)
		if split_into_array:
			modData = modData.split("\n")
		if modMainPath != null:
			return modData
		else:
			return null
	
	
	
	
	
	

class _ManifestV2:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	func _init(d):
		pointers = d
	
	var file:File = File.new()
	
	var cached_mod_list : Dictionary = {}
	
	func __get_mod_data(print_json: bool = false):
		if not cached_mod_list.empty():
			if print_json:
				var psj = JSON.print(cached_mod_list, "\t")
				return psj
			else:
				return cached_mod_list.duplicate(true)
		else:
			pointers.l("Fetching mods from file","pointers.ManifestV2")
			var mod_dictionary : Dictionary = {}
			var manifest_count:int = 0
			var library_count:int = 0
			var non_library_count:int = 0
			var total_mod_count:int = 0
			# FUTURE ME: FIX THIS TO USE PARSE TAGS
			var stat_tags : Dictionary = {}
			
			var modListArr : Array = []
			var modmain_files : Array = __get_modmain_files()
			pointers.l("found [%s] modmain files" % modmain_files.size(),"pointers.ManifestV2")
			for item in modmain_files:
				pointers.l("registering ModMain %s" % item,"pointers.ManifestV2")
				modListArr.append(__concat_mod_info(item))
#				modListArr.append({"constants":constants,"script_path":item,"node":(modNodes[item]) if (is_onready or item in modNodes) else (null)})
			var modlet_files : Array = __get_modlet_files()
			pointers.l("found [%s] modlet files" % modlet_files.size(),"pointers.ManifestV2")
			for item in modlet_files:
				pointers.l("registering Modlet %s" % item,"pointers.ManifestV2")
				modListArr.append(__concat_mod_info(item))
			total_mod_count = modListArr.size()
			var totalSTDOUT = "solved [%s] mod-definition files [%s ModMains / %s Modlets]" % [total_mod_count,modmain_files.size(),modlet_files.size()]
			print("[pointers.ManifestV2]: " + totalSTDOUT)
			pointers.l(totalSTDOUT,"pointers.ManifestV2")
			modListArr.sort_custom(self,"sortModList")
			
			for mod in modListArr:
				
				var mod_entry : Dictionary = __make_mod_entry(mod)
				var manifest_data : Dictionary = mod_entry["manifest"]["manifest_data"]
				if mod_entry["manifest"]["has_manifest"]:
					manifest_count += 1
				if "tags" in manifest_data:
					for tag in manifest_data["tags"]:
						if tag in stat_tags:
							stat_tags[tag] += 1
						else:
							stat_tags.merge({tag:1})
				mod_dictionary.merge({mod.get("script_path",""):mod_entry})
				
				if mod_entry["library_information"]["is_library"]:
					library_count += 1
				else:
					non_library_count += 1
			
			
			var stat_count : Dictionary = {"total_mod_count":total_mod_count,"mods_using_manifests":manifest_count,"mods":non_library_count,"libraries":library_count}
			var statistics : Dictionary = {"counts":stat_count,"tags":stat_tags}
			var returnValues : Dictionary = {"mods":mod_dictionary,"statistics":statistics}
			cached_mod_list = returnValues.duplicate(true)
			if print_json:
				var psj : String = JSON.print(cached_mod_list, "\t")
				return psj
			else:
				return cached_mod_list.duplicate(true)
	
	func __concat_mod_info(mod_path:String) -> Dictionary:
		if not pointers.DataFormat.__file_exists(mod_path):
			return {}
		var cv : String = mod_path.get_file().to_lower()
		if cv.begins_with("modmain") and cv.ends_with(".gd"):
			var constants : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load(mod_path)
			return {"constants":constants,"script_path":mod_path,"mod_type":"mod"}
		elif cv.begins_with("mod") and cv.ends_with(".manifest"):
			var manifestData : Dictionary = __parse_file_as_manifest(mod_path)
			var constants = {
				"MOD_PRIORITY":manifestData["manifest_definitions"].get("modlet_priority",0),
				"MOD_NAME":manifestData["mod_information"].get("name",mod_path.split("/")[2]),
				"MOD_VERSION":manifestData["version"].get("version_string","1.0.0"),
				"MOD_VERSION_MAJOR":manifestData["version"].get("version_major","1"),
				"MOD_VERSION_MINOR":manifestData["version"].get("version_minor","0"),
				"MOD_VERSION_BUGFIX":manifestData["version"].get("version_bugfix","0"),
				"MOD_VERSION_METADATA":manifestData["version"].get("version_metadata",""),
				"MOD_IS_LIBRARY":manifestData["library"].get("is_library",false),
				"ALWAYS_DISPLAY":manifestData["library"].get("always_display",false),
			}
			return {"constants":constants,"script_path":mod_path,"mod_type":"modlet"}
		return {}
	
	func __make_mod_entry(mod: Dictionary):
		var constants : Dictionary = mod.get("constants")
		var script_path : String = mod.get("script_path")
		var folder_path : String = script_path.get_base_dir() + "/"
		var mod_priority : int = constants.get("MOD_PRIORITY",0)
		var mod_name : String = str(constants.get("MOD_NAME",script_path.split("/")[2]))
		var legacy_mod_version : String = constants.get("MOD_VERSION","1.0.0")
		var mod_version_major : int = constants.get("MOD_VERSION_MAJOR",1)
		var mod_version_minor : int = constants.get("MOD_VERSION_MINOR",0)
		var mod_version_bugfix : int = constants.get("MOD_VERSION_BUGFIX",0)
		var mod_version_metadata : String = constants.get("MOD_VERSION_METADATA","")
		var is_library : bool = constants.get("MOD_IS_LIBRARY",false)
		var always_display : bool = constants.get("ALWAYS_DISPLAY",false)
		
		var has_mod_manifest : bool = false
		var manifest_data : Dictionary = {}
		var manifest_version : float = 1.0
		var has_icon_file : bool = false
		var png_path := ""
		var stex_path := ""
		var icon_path := ""
		var content : Array = __get_manifest_files() + __get_icon_files()
		
		var mod_enabled := true
		var script_filename : String = script_path.get_file().to_lower()
		
		if script_filename.begins_with("mod") and script_filename.ends_with(".manifest"):
			var current : Array = __get_modlet_files()
			if not script_path in current:
				mod_enabled = false
		
		for content_file in content:
			if content_file.begins_with(folder_path):
				var ft : String = content_file.split(folder_path)[1]
				if ft.to_lower() == "mod.manifest":
					has_mod_manifest = true
					
					manifest_data = __parse_file_as_manifest(content_file)
					mod_name = manifest_data["mod_information"].get("name",mod_name)
					legacy_mod_version = manifest_data["version"].get("version_string",legacy_mod_version)
					mod_version_major = manifest_data["version"].get("version_major",mod_version_major)
					mod_version_minor = manifest_data["version"].get("version_minor",mod_version_minor)
					mod_version_bugfix = manifest_data["version"].get("version_bugfix",mod_version_bugfix)
					mod_version_metadata = manifest_data["version"].get("version_metadata",mod_version_metadata)
					is_library = manifest_data["library"].get("is_library",false)
					always_display = manifest_data["library"].get("always_display",false)
					manifest_version = manifest_data["manifest_definitions"].get("manifest_version",1)
					
					
					
				if ft.to_lower().begins_with("icon"):
					if ft.to_lower().ends_with(".png"):
						has_icon_file = true
						png_path = content_file
					if ft.to_lower().ends_with(".stex"):
						has_icon_file = true
						stex_path = content_file
		if stex_path:
			icon_path = stex_path
		elif png_path:
			icon_path = png_path
		var icon_dict : Dictionary = {"has_icon_file":has_icon_file,"icon_path":icon_path}
		var manifestEntry : Dictionary = {"has_manifest":has_mod_manifest,"manifest_version":manifest_version,"manifest_data":manifest_data}
		var mod_version_array : Array = [mod_version_major,mod_version_minor,mod_version_bugfix]
		var mod_version_string : String = str(mod_version_major) + "." + str(mod_version_minor) + "." + str(mod_version_bugfix)
		if not str(mod_version_metadata) == "":
			mod_version_array.append(mod_version_metadata)
			mod_version_string = mod_version_string + "-" + str(mod_version_metadata)
		var version_dictionary : Dictionary = {"version_major":mod_version_major,"version_minor":mod_version_minor,"version_bugfix":mod_version_bugfix,"version_metadata":mod_version_metadata,"full_version_array":mod_version_array,"full_version_string":mod_version_string,"legacy_mod_version":legacy_mod_version}
		var drivers : Dictionary = pointers.DriverManagement.__get_drivers_from_modmain_path(script_path)
		var ml : String = "en"
		if "REPLACE_TRANSLATIONS.gd" in drivers:
			var tlData : Dictionary = drivers["REPLACE_TRANSLATIONS.gd"]["TRANSLATIONS"]
			ml = tlData.get("master_locale","en")
			tlData.erase("master_locale")
			tlData.erase("file")
			var master_locale : Dictionary = tlData.get(ml,{})
			var total : int = master_locale.size()
			var counts : Dictionary = {ml:{"has":total,"missing":0,"not_updated":0}}
			for lang in tlData:
				if lang != ml:
					var langData : Dictionary = tlData[lang]
					var lc : int = langData.size()
					var not_in_master:int = 0
					var not_updated:int = 0
					for l in langData:
						if not l in master_locale:
							not_in_master += 1
						else:
							if langData[l].get("version_hash",0) != hash(master_locale[l].get("string","")):
								not_updated += 1
					counts[lang] = {"has":lc,"missing":total - (lc - not_in_master),"not_updated":not_updated}
					counts[ml]["missing"] += not_in_master
			if manifestEntry["has_manifest"]:
				var manifest_langs = {}
				for lang in counts:
					var hs : float = float(counts[lang]["has"])
					var ms : float = float(counts[lang]["missing"])
					var nu : float = float(counts[lang]["not_updated"])
					var not_updated_factor : float = 25 * (1 - ((hs - nu) / hs))
					var bucket : float = hs/(hs+ms)
					var percent : float = bucket * 100
					var adjusted : float = percent - not_updated_factor
					manifest_langs[lang] = "%3.1f%%" % [adjusted]
				
				
				manifestEntry["manifest_data"]["languages"] = manifest_langs
		return {"name":mod_name,"priority":mod_priority,"file_path":script_path,"version_data":version_dictionary,"mod_icon":icon_dict,"library_information":{"is_library":is_library,"always_display":always_display},"manifest":manifestEntry,"drivers":drivers,"mod_type":mod["mod_type"],"enabled":mod_enabled,"master_locale":ml}
	
	static func sortModList(a,b):
		var c1:int = a.get("constants",{}).get("MOD_PRIORITY",0)
		var c2:int = b.get("constants",{}).get("MOD_PRIORITY",0)
		if c1 != c2:
			return c1 < c2
		var b1:PoolByteArray = a.get("mod_path","").to_ascii()#.split("/")
		var b2:PoolByteArray = b.get("mod_path","").to_ascii()#.split("/")
		if b1 != b2:
			return b1 < b2
		return false
	
	var cached_zip_refs : Dictionary = {}
	
	func __match_mod_path_to_zip(mod_main_path:String) -> String:
		if mod_main_path in cached_zip_refs:
			return cached_zip_refs[mod_main_path]
		else:
			var zip_ref_store : String = "user://cache/.HevLib_Cache/zip_ref_store.json"
			var file:File = File.new()
			file.open(zip_ref_store,File.READ)
			var data : Dictionary = JSON.parse(file.get_as_text()).result
			file.close()
			var return_val : String = data.get(mod_main_path,"")
			cached_zip_refs[mod_main_path] = return_val
			return return_val
	
	func __compare_versions(checked_mod_data:Dictionary) -> bool:
		var installed_mods : Dictionary = __get_mod_data()
		var check_keys : Array = checked_mod_data.keys()
		var check_name : String = checked_mod_data[check_keys[0]].get("name","")
		var installed_dict : Dictionary = {}
		for installed_mod in installed_mods["mods"]:
			var installed_mName : String = installed_mods["mods"][installed_mod].get("name","")
			if installed_mName == check_name:
				installed_dict = installed_mods["mods"][installed_mod].duplicate()
		if installed_dict.keys().size() == 0:
			return false
		var checked_manifest_version:float = checked_mod_data[check_keys[0]]["manifest"]["manifest_version"]
		var installed_manifest_version:float = installed_dict["manifest"]["manifest_version"]
		if checked_manifest_version <= 1:
			return false
		if checked_manifest_version > installed_manifest_version:
			return true
		var checked_mod_version : Array = checked_mod_data[check_keys[0]]["version_data"]["full_version_array"]
		var installed_mod_version : Array = installed_dict["version_data"]["full_version_array"]
		if checked_mod_version[0] > installed_mod_version[0]:
			return true
		if checked_mod_version[1] > installed_mod_version[1]:
			return true
		if checked_mod_version[2] > installed_mod_version[2]:
			return true
		return false
	
	func __get_mod_data_from_files(script_path:String) -> Dictionary:
		var constants : Dictionary = pointers.DataFormat.__get_script_constant_map_without_load(script_path)
		var folder_path : String = script_path.get_base_dir() + "/"
		var mod_priority:int = constants.get("MOD_PRIORITY",0)
		var mod_name : String = str(constants.get("MOD_NAME",script_path.split("/")[2]))
		var legacy_mod_version : String = constants.get("MOD_VERSION","1.0.0")
		var mod_version_major:int = constants.get("MOD_VERSION_MAJOR",1)
		var mod_version_minor:int = constants.get("MOD_VERSION_MINOR",0)
		var mod_version_bugfix:int = constants.get("MOD_VERSION_BUGFIX",0)
		var mod_version_metadata : String = constants.get("MOD_VERSION_METADATA","")
		
		var mod_is_library:bool = constants.get("MOD_IS_LIBRARY",false)
		
		var hide_library:bool = constants.get("LIBRARY_HIDDEN_BY_DEFAULT",true)
		var content : Array = __get_manifest_files()
		var has_mod_manifest:bool = false
		var manifest_data : Dictionary = {}
		var manifest_version:float = 1.0
		var has_icon_file:bool = false
		var icon_path : String = ""
		var png_path : String = ""
		var stex_path : String = ""
		for file in content:
			if file.to_lower() == folder_path.to_lower() + "mod.manifest":
				has_mod_manifest = true
				manifest_data = __parse_file_as_manifest(folder_path + file, true)
				mod_name = manifest_data["mod_information"].get("name",mod_name)
				legacy_mod_version = manifest_data["version"].get("version_string",legacy_mod_version)
				mod_version_major = manifest_data["version"].get("version_major",mod_version_major)
				mod_version_minor = manifest_data["version"].get("version_minor",mod_version_minor)
				mod_version_bugfix = manifest_data["version"].get("version_bugfix",mod_version_bugfix)
				mod_version_metadata = manifest_data["version"].get("version_metadata",mod_version_metadata)
				mod_is_library = manifest_data["tags"].get("is_library_mod",false)
				hide_library = manifest_data["tags"].get("library_hidden_by_default",true)
				if file.to_lower().begins_with("icon"):
					if file.to_lower().ends_with(".png"):
						has_icon_file = true
						png_path = folder_path + file
					if file.to_lower().ends_with(".stex"):
						has_icon_file = true
						stex_path = folder_path + file
		if stex_path:
			icon_path = stex_path
		elif png_path:
			icon_path = png_path
		var icon_dict : Dictionary = {"has_icon_file":has_icon_file,"icon_path":icon_path}
		var manifestEntry : Dictionary = {"has_manifest":has_mod_manifest,"manifest_version":manifest_version,"manifest_data":manifest_data}
		var mod_version_array : Array = [mod_version_major,mod_version_minor,mod_version_bugfix]
		var mod_version_string : String = str(mod_version_major) + "." + str(mod_version_minor) + "." + str(mod_version_bugfix)
		if not str(mod_version_metadata) == "":
			mod_version_array.append(mod_version_metadata)
			mod_version_string = mod_version_string + "-" + str(mod_version_metadata)
		var version_dictionary : Dictionary = {"version_major":mod_version_major,"version_minor":mod_version_minor,"version_bugfix":mod_version_bugfix,"version_metadata":mod_version_metadata,"full_version_array":mod_version_array,"full_version_string":mod_version_string,"legacy_mod_version":legacy_mod_version}
		var mod_entry : Dictionary = {str(script_path):{"name":mod_name,"priority":mod_priority,"version_data":version_dictionary,"mod_icon":icon_dict,"library_information":{"is_library":mod_is_library,"keep_library_hidden":hide_library},"manifest":manifestEntry}}
		return(mod_entry)
	
	var cached_manifests : Dictionary = {}
	
	func __parse_file_as_manifest(file_path: String, format_to_manifest_version: bool = true) -> Dictionary:
		var cachevar : String = file_path + ":" + str(format_to_manifest_version)
		if cachevar in cached_manifests:
			return cached_manifests[cachevar].duplicate(true)
		else:
			var out : Dictionary = {}
			var cfg : Dictionary = pointers.ConfigDriver.__config_parse(file_path)
			var manifest_data : Dictionary = {}
			var manifest_version:float = 1.0
			if "manifest_definitions" in cfg:
				manifest_version = cfg["manifest_definitions"].get("manifest_version",manifest_version)
				var tpf:int = typeof(manifest_version)
				if not (tpf == TYPE_INT or tpf == TYPE_REAL):
					manifest_version = 1.0
			manifest_data = cfg
			if format_to_manifest_version:
				var dict_template : Dictionary = {
					"mod_information":{
						"name":"",
						"id":"",
						"description":"",
						"brief":"",
						"author":"",
						"credits":PoolStringArray([])
					},
					"version":{
						"version_major":1,
						"version_minor":0,
						"version_bugfix":0,
						"version_metadata":"",
						"version_string":"1.0.0"
					},
					"tags":{
						
					},
					"links":{
						
					},
					"configs":{
						
					},
					"languages":{
						
					},
					"library":{
						"is_library":false,
						"always_display":false,
					},
					"manifest_definitions":{
						"manifest_version":1.0,
						"dependancy_mod_ids":PoolStringArray([]),
						"conflicting_mod_ids":PoolStringArray([]),
						"complementary_mod_ids":PoolStringArray([]),
						"manifest_url":"", # EXAMPLE: https://raw.githubusercontent.com/rwqfsfasxc100/HevLib/main/Mod.manifest
						"changelog_path":"", # This is relative to the ModMain.gd file. EXAMPLE: for a file at 'res://Example Mod/data/folder/changelogs.txt', you would put 'data/folder/changelogs.txt'
						"modlet_priority":0, # SPECIFIC TO MODLETS! The order at which the modlet would be loaded. Most modlets load before other mods, but this will affect load order within the list of installed modlets
					}
				}
				match manifest_version:
					1.0:
						dict_template["mod_information"]["id"] = manifest_data["package"].get("id","")
						dict_template["mod_information"]["name"] = manifest_data["package"].get("name","")
						var version = manifest_data["package"].get("version","unknown")
						dict_template["mod_information"]["description"] = manifest_data["package"].get("description","MODMENU_DESCRIPTION_PLACEHOLDER")
						
						if typeof(manifest_data["package"].get("github_homepage","")) == TYPE_STRING:
							var url = manifest_data["package"]["github_homepage"]
							if url != "":
								dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
						var discURL = manifest_data["package"].get("discord","")
						if discURL != "":
							dict_template["links"].merge({"HEVLIB_DISCORD":{"URL":discURL}})
						var nexusURL = manifest_data["package"].get("nexus","")
						if nexusURL != "":
							dict_template["links"].merge({"HEVLIB_NEXUS":{"URL":nexusURL}})
						var donationURL = manifest_data["package"].get("donations","")
						if donationURL != "":
							dict_template["links"].merge({"HEVLIB_DONATIONS":{"URL":donationURL}})
						var wikiURL = manifest_data["package"].get("wiki","")
						if wikiURL != "":
							dict_template["links"].merge({"HEVLIB_WIKI":{"URL":wikiURL}})
						
					2.0:
						dict_template["mod_information"]["id"] = manifest_data["package"].get("id","")
						dict_template["mod_information"]["name"] = manifest_data["package"].get("name","")
						dict_template["version"]["version_major"] = manifest_data["package"].get("version_major",1)
						dict_template["version"]["version_minor"] = manifest_data["package"].get("version_minor",0)
						dict_template["version"]["version_bugfix"] = manifest_data["package"].get("version_bugfix",0)
						dict_template["version"]["version_metadata"] = manifest_data["package"].get("version_metadata","")
						dict_template["mod_information"]["description"] = manifest_data["package"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER")
						if typeof(manifest_data["package"].get("github","")) == TYPE_DICTIONARY:
							var url = manifest_data["package"]["github"]["link"]
							if url != "":
								dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
						elif typeof(manifest_data["package"].get("github","")) == TYPE_STRING:
							var url = manifest_data["package"]["github"]
							if url != "":
								dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
						var discURL = manifest_data["package"].get("discord","")
						if discURL != "":
							dict_template["links"].merge({"HEVLIB_DISCORD":{"URL":discURL}})
						var nexusURL = manifest_data["package"].get("nexus","")
						if nexusURL != "":
							dict_template["links"].merge({"HEVLIB_NEXUS":{"URL":nexusURL}})
						var donationURL = manifest_data["package"].get("donations","")
						if donationURL != "":
							dict_template["links"].merge({"HEVLIB_DONATIONS":{"URL":donationURL}})
						var wikiURL = manifest_data["package"].get("wiki","")
						if wikiURL != "":
							dict_template["links"].merge({"HEVLIB_WIKI":{"URL":wikiURL}})
						dict_template["mod_information"]["author"] = manifest_data["package"].get("author","Unknown")
						dict_template["mod_information"]["credits"] = manifest_data["package"].get("credits",[])
						
					2.1:
						# information
						if "mod_information" in manifest_data:
							dict_template["mod_information"]["id"] = String(manifest_data["mod_information"].get("id",""))
							dict_template["mod_information"]["name"] = String(manifest_data["mod_information"].get("name",""))
							dict_template["mod_information"]["description"] = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
							dict_template["mod_information"]["author"] = String(manifest_data["mod_information"].get("author","Unknown"))
							dict_template["mod_information"]["credits"] = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
						
						# versioning
						if "version" in manifest_data:
							dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
							dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
							dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
							dict_template["version"]["version_metadata"] = String(manifest_data["version"].get("version_metadata",""))
						
						# tags
						if "tags" in manifest_data:
							var current_tags = manifest_data["tags"]
							if "allow_achievements" in current_tags:
								dict_template["tags"].merge({"TAG_ALLOW_ACHIEVEMENTS":{"type":"boolean","value":manifest_data["tags"].get("allow_achievements")}})
							if "quality_of_life" in current_tags:
								dict_template["tags"].merge({"TAG_QOL":{"type":"boolean","value":manifest_data["tags"].get("quality_of_life")}})
							if "is_library_mod" in current_tags:
								dict_template["library"]["is_library"] = manifest_data["tags"].get("is_library_mod")
							if "uses_hevlib_research" in current_tags:
								dict_template["tags"].merge({"TAG_USING_HEVLIB_RESEARCH":{"type":"boolean","value":manifest_data["tags"].get("uses_hevlib_research")}})
							if "overhaul" in current_tags:
								dict_template["tags"].merge({"TAG_OVERHAUL":{"type":"bool","value":manifest_data["tags"].get("overhaul")}})
							if "visual" in current_tags:
								dict_template["tags"].merge({"TAG_VISUAL":{"type":"bool","value":manifest_data["tags"].get("visual")}})
							if "fun" in current_tags:
								dict_template["tags"].merge({"TAG_FUN":{"type":"bool","value":manifest_data["tags"].get("fun")}})
							if "user_interface" in current_tags:
								dict_template["tags"].merge({"TAG_UI":{"type":"bool","value":manifest_data["tags"].get("user_interface")}})
							
							if "adds_ships" in current_tags:
								dict_template["tags"].merge({"TAG_ADDS_SHIPS":{"type":"array","value":manifest_data["tags"].get("adds_ships")}})
							if "adds_equipment" in current_tags:
								dict_template["tags"].merge({"TAG_ADDS_EQUIPMENT":{"type":"array","value":manifest_data["tags"].get("adds_equipment")}})
							if "adds_gameplay_mechanics" in current_tags:
								dict_template["tags"].merge({"TAG_ADDS_GAMEPLAY_MECHANICS":{"type":"array","value":manifest_data["tags"].get("adds_gameplay_mechanics")}})
							if "adds_events" in current_tags:
								dict_template["tags"].merge({"TAG_ADDS_EVENTS":{"type":"array","value":manifest_data["tags"].get("adds_events")}})
							
							if "handle_extra_crew" in current_tags:
								dict_template["tags"].merge({"TAG_HANDLE_EXTRA_CREW":{"type":"integer","value":manifest_data["tags"].get("handle_extra_crew")}})
							
						# links
						if "links" in manifest_data:
							if typeof(manifest_data["links"].get("github","")) == TYPE_DICTIONARY:
								var url = manifest_data["links"]["github"]["link"]
								if url != "":
									dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
							elif typeof(manifest_data["links"].get("github","")) == TYPE_STRING:
								var url = manifest_data["links"]["github"]
								if url != "":
									dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
							var discURL = manifest_data["links"].get("discord","")
							if discURL != "":
								dict_template["links"].merge({"HEVLIB_DISCORD":{"URL":discURL}})
							var nexusURL = manifest_data["links"].get("nexus","")
							if nexusURL != "":
								dict_template["links"].merge({"HEVLIB_NEXUS":{"URL":nexusURL}})
							var donationURL = manifest_data["links"].get("donations","")
							if donationURL != "":
								dict_template["links"].merge({"HEVLIB_DONATIONS":{"URL":donationURL}})
							var wikiURL = manifest_data["links"].get("wiki","")
							if wikiURL != "":
								dict_template["links"].merge({"HEVLIB_WIKI":{"URL":wikiURL}})
							var bugreportsURL = manifest_data["links"].get("bug_reports","")
							if bugreportsURL != "":
								dict_template["links"].merge({"HEVLIB_BUGREPORTS":{"URL":bugreportsURL}})
						
						# manifest definitions
						if "manifest_definitions" in manifest_data:
							dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
							dict_template["manifest_definitions"]["dependancy_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
							dict_template["manifest_definitions"]["conflicting_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
							dict_template["manifest_definitions"]["complementary_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
					2.2:
						
						if "mod_information" in manifest_data:
							dict_template["mod_information"]["id"] = String(manifest_data["mod_information"].get("id",""))
							dict_template["mod_information"]["name"] = String(manifest_data["mod_information"].get("name",""))
							dict_template["mod_information"]["description"] = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
							dict_template["mod_information"]["brief"] = String(manifest_data["mod_information"].get("brief",""))
							dict_template["mod_information"]["author"] = String(manifest_data["mod_information"].get("author","Unknown"))
							dict_template["mod_information"]["credits"] = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
						
						if "version" in manifest_data:
							dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
							dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
							dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
							dict_template["version"]["version_metadata"] = String(manifest_data["version"].get("version_metadata",""))
						
						if "manifest_definitions" in manifest_data:
							dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
							dict_template["manifest_definitions"]["dependancy_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
							dict_template["manifest_definitions"]["conflicting_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
							dict_template["manifest_definitions"]["complementary_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
							dict_template["manifest_definitions"]["manifest_url"] = String(manifest_data["manifest_definitions"].get("manifest_url",""))
							dict_template["manifest_definitions"]["changelog_path"] = String(manifest_data["manifest_definitions"].get("changelog_path",""))
							dict_template["manifest_definitions"]["modlet_priority"] = int(manifest_data["manifest_definitions"].get("modlet_priority",0))
						
						if "links" in manifest_data:
							var links = manifest_data["links"]
							var ovLinks = {}
							for link in links:
								var ld = links[link]
								if typeof(ld) == TYPE_DICTIONARY:
									if "URL" in ld and typeof(ld.URL) == TYPE_STRING:
										ovLinks[link] = ld
							if ovLinks:
								dict_template["links"] = ovLinks
						if "tags" in manifest_data:
							var tags = manifest_data["tags"]
							var ovTags = {}
							for tag in tags:
								var td = tags[tag]
								if typeof(td) == TYPE_DICTIONARY:
									if "type" in td and "value" in td and typeof(td.type) == TYPE_STRING:
										ovTags[tag] = td
							if ovTags:
								dict_template["tags"] = ovTags
						if "languages" in manifest_data:
							var languages = manifest_data["languages"]
							for language in languages:
								var ld = languages[language]
								var tld = typeof(ld)
								if tld == TYPE_STRING:
									dict_template["languages"][language] = ld
								elif tld == TYPE_INT or tld == TYPE_REAL:
									dict_template["languages"][language] = str(ld) + "%"
						if "library" in manifest_data:
							dict_template["library"]["is_library"] = manifest_data["library"].get("is_library",false)
							dict_template["library"]["always_display"] = manifest_data["library"].get("always_display",false)
							
						if "configs" in manifest_data:
							var configs = manifest_data["configs"]
							var ovConfigs = {}
							for section in configs:
								var sec_data = configs[section]
								for cfname in sec_data:
									var cfdata = sec_data[cfname]
									if not cfdata.get("disabled",false):
										if not section in ovConfigs:
											ovConfigs[section] = {}
										ovConfigs[section][cfname] = cfdata
							if ovConfigs:
								pointers.l("Parsed configs for %s, has disabled configs: [%s]" % [file_path,str(hash(configs) != hash(ovConfigs))],"pointers.ManifestV2")
								dict_template["configs"] = ovConfigs
						
						
				var version_metadata : String = dict_template["version"]["version_metadata"]
				var version_string : String = str(dict_template["version"]["version_major"]) + "." + str(dict_template["version"]["version_minor"]) + "." + str(dict_template["version"]["version_bugfix"])
				if not version_metadata == "":
					version_string = version_string + "-" + version_metadata
				dict_template["version"]["version_string"] = version_string
				out = dict_template
			else:
				out = manifest_data
			cached_manifests[cachevar] = out.duplicate(true)
			return out
	
	func __get_mod_by_id(id:String, case_sensitive: bool = true) -> Dictionary:
		var mods : Dictionary = {}
		if not cached_mod_list.empty():
			mods = cached_mod_list["mods"]
		else:
			var data : Dictionary = __get_mod_data()
			mods = data["mods"]
		for mod in mods:
			var ID : String = ""
			var moddata : Dictionary = mods.get(mod)
			var manifest : Dictionary = moddata["manifest"]["manifest_data"]
			if manifest:
				if "mod_information" in manifest:
					ID = manifest["mod_information"].get("id","")
			var matches:bool = false
			if case_sensitive:
				if id.to_upper() == ID.to_upper():
					matches = true
			else:
				if id == ID:
					matches = true
			if matches:
				return moddata
		return {}
	
	var tag_data_cache = {}
	
	func __get_tags() -> Dictionary:
		if tag_data_cache:
			return tag_data_cache.duplicate(true)
		else:
			var tag_dict : Dictionary = {}
			var mods : Dictionary = __get_mod_data()["mods"]
			for mod in mods:
				if mods[mod]["manifest"]["has_manifest"]:
					var md : Dictionary = mods[mod]["manifest"]["manifest_data"]
					var id : String = md["mod_information"].get("id","")
					if id and "tags" in md:
						var tags : Dictionary = md["tags"]
						for tag in tags:
							if not tag in tag_dict:
								tag_dict[tag] = {}
							if typeof(tags[tag]) == TYPE_DICTIONARY:
								var td : Dictionary = tags[tag]
								if "value" in td and "type" in td and typeof(td.type) == TYPE_STRING:
									tag_dict[tag][id] = td["value"]
			return tag_dict
	
	func __get_mod_tags(mod_id: String) -> Dictionary:
		var tag_dict : Dictionary = {}
		var tags : Dictionary = __get_tags()
		for tag in tags:
			var td : Dictionary = tags[tag]
			if mod_id in td:
				if not tag in tag_dict:
					tag_dict[tag] = null
				tag_dict[tag] = td[mod_id]
		return tag_dict
	
	func __get_mods_from_tag(tag_name: String) -> Array:
		return __get_tags().get(tag_name,{}).keys()
	
	func __get_mods_and_tags_from_tag(tag_name: String) -> Dictionary:
		
		# REFACTOR TO USE __parse_tags
		
		var alldata : Dictionary = __get_tags()
		var data : Dictionary = alldata.get(tag_name,{})
		var ex_data : Dictionary = {}
		if data:
			for mod in data:
				match tag_name:
					"TAG_ADDS_EQUIPMENT","TAG_ADDS_EVENTS","TAG_ADDS_GAMEPLAY_MECHANICS","TAG_ADDS_SHIPS":
						var k : Array = data.get(mod,[])
						if k:
							var equip : Array = []
							for lang in k:
								equip.append(lang)
							ex_data[mod] = equip
					"TAG_HANDLE_EXTRA_CREW":
						var k:int = data.get(mod,24)
						if k > 24:
							ex_data[mod] = k
					_:
						var k:bool = data.get(mod,false)
						ex_data[mod] = k
		return ex_data
	
	func __get_manifest_section(section: String, mod_id: String = "") -> Dictionary:
		var manifest_data_cache : Dictionary = __get_manifest_cache()
		var mode:int = 0
		var return_data : Dictionary = {}
		if mod_id != "":
			mode = 1
		match mode:
			0:
				for mod in manifest_data_cache:
					var manifest : Dictionary = manifest_data_cache[mod]
					if section in manifest:
						return_data[mod] = manifest[section]
					
			1:
				for mod in manifest_data_cache:
					if mod_id in __get_mod_ids():
						var manifest : Dictionary = manifest_data_cache[mod]
						if "mod_information" in manifest:
							if mod_id in manifest["mod_information"]["id"]:
								if section in manifest:
									return_data = manifest[section]
		
		return return_data
	
	func __get_manifest_entry(section: String, entry: String, mod_id: String = ""):
		var manifest_data_cache : Dictionary = __get_manifest_cache()
		var mode:int = 0
		var return_data : Dictionary = {}
		if mod_id != "":
			mode = 1
		match mode:
			0:
				for mod in manifest_data_cache:
					var manifest : Dictionary = manifest_data_cache[mod]
					if section in manifest:
						return_data[mod] = manifest[section]
					
			1:
				for mod in manifest_data_cache:
					if mod_id in __get_mod_ids():
						var manifest : Dictionary = manifest_data_cache[mod]
						if "mod_information" in manifest:
							if mod_id in manifest["mod_information"]["id"]:
								if section in manifest:
									return_data = manifest[section]
		
		var sec = return_data
		
		var nmode:int = 0
		if mod_id != "":
			nmode = 1
		match nmode:
			0:
				var dict : Dictionary = {}
				for mod in sec:
					var id : String = manifest_data_cache[mod]["mod_information"]["id"]
					if entry in sec[mod]:
						var e = sec[mod][entry]
						dict.merge({id:e})
				return dict
			1:
				if entry in sec:
					return sec[entry]
		return {}
	
	var caches_mod_ids : Array = []
	
	func __get_mod_ids() -> Array:
		if caches_mod_ids:
			return caches_mod_ids.duplicate(true)
		else:
			var mod_data : Dictionary = {}
			if not cached_mod_list.empty():
				mod_data = cached_mod_list["mods"]
			else:
				mod_data = __get_mod_data()["mods"]
			var returning : Array = []
			for mod in mod_data:
				var data : Dictionary = mod_data[mod]["manifest"]["manifest_data"]
				if "mod_information" in data:
					var minfo : String = data["mod_information"]["id"]
					returning.append(minfo)
			caches_mod_ids = returning.duplicate(true)
			return returning
	
	
	func __check_complementary():
		var mods : Dictionary = {}
		if not cached_mod_list.empty():
			mods = cached_mod_list["mods"]
		else:
			mods = __get_mod_data()["mods"]
		var tags : Dictionary = __get_manifest_entry("manifest_definitions","complementary_mod_ids")
		var complimentaries : Dictionary = {}
		for mod in tags:
			var keys = tags[mod]
			if keys:
				var items : Array = []
				for item in keys:
					if item in mods:
						items.append(item)
				if items:
					complimentaries.merge({mod:items})
		return complimentaries
	
	func __check_mod_complementary(mod_id):
		var mods : Dictionary = {}
		if not cached_mod_list.empty():
			mods = cached_mod_list["mods"]
		else:
			mods = __get_mod_data()["mods"]
		var tags : Dictionary = __get_manifest_entry("manifest_definitions","complementary_mod_ids",mod_id)
		var complimentaries : Array = []
		for mod in tags:
			if mod in mods:
				complimentaries.append(mod)
		return complimentaries
	
	func __check_dependancies():
		var mods : Array = __get_mod_ids()
		var tags : Dictionary = __get_manifest_entry("manifest_definitions","dependancy_mod_ids")
		var complimentaries : Dictionary = {}
		for mod in tags:
			var keys = tags[mod]
			if keys:
				var items : Array = []
				for item in keys:
					if not item in mods:
						items.append(item)
				if items:
					complimentaries.merge({mod:items})
		return complimentaries
	
	func __check_mod_dependancies(mod_id):
		var mods : Array = __get_mod_ids()
		var tags : Dictionary = __get_manifest_entry("manifest_definitions","dependancy_mod_ids",mod_id)
		var complimentaries : Array = []
		for mod in tags:
			if not mod in mods:
				complimentaries.append(mod)
		return complimentaries
	
	func __check_conflicts():
		var mods : Array = __get_mod_ids()
		var tags : Dictionary = __get_manifest_entry("manifest_definitions","conflicting_mod_ids")
		var complimentaries : Dictionary = {}
		for mod in tags:
			var keys = tags[mod]
			if keys:
				var items : Array = []
				for item in keys:
					if item in mods:
						items.append(item)
				if items:
					complimentaries.merge({mod:items})
		return complimentaries
	
	func __check_mod_conflicts(mod_id):
		var mods : Array = __get_mod_ids()
		var tags : Dictionary = __get_manifest_entry("manifest_definitions","conflicting_mod_ids",mod_id)
		var complimentaries : Array = []
		for mod in tags:
			if mod in mods:
				complimentaries.append(mod)
		return complimentaries
	
	func __parse_tags(tag_data) -> Dictionary:
		var tag_dict : Dictionary = {}
		for entry in tag_data:
			var type:int = typeof(tag_data[entry])
			if type != TYPE_DICTIONARY:
				return tag_dict
			var tag_type : String = tag_data[entry].get("type","NULL_TYPE")
			tag_type = tag_type.to_lower()
			match tag_type:
				"boolean","bool":
					var val:bool = bool(tag_data[entry].get("value"))
					tag_dict.merge({entry:val})
				"string","str":
					var val : String = str(tag_data[entry].get("value"))
					tag_dict.merge({entry:val})
				"integer","int":
					var val:int = int(tag_data[entry].get("value"))
					tag_dict.merge({entry:val})
				"array","arr":
					var val : Array = Array(tag_data[entry].get("value"))
					tag_dict.merge({entry:val})
				_:
					var val = tag_data[entry].get("value")
					tag_dict.merge({entry:val})
		return tag_dict
	
	func __have_mods_updated(folder = "user://cache/.Mod_Menu_2_Cache/changelogs/",last_seen_file = "mods_from_last_launch.json") -> Dictionary:
		if not folder.ends_with("/"):
			folder = folder + "/"
		if last_seen_file.begins_with("/"):
			last_seen_file.lstrip("/")
		var all_mods : Dictionary = __get_mod_data()["mods"]
		pointers.FolderAccess.__check_folder_exists(folder)
		if not file.file_exists(folder + last_seen_file):
			file.open(folder + last_seen_file,File.WRITE)
			file.store_string("{}")
			file.close()
		var mods : Dictionary = {}
		for mod in all_mods:
			var data : Dictionary = all_mods[mod]
			if data["manifest"]["has_manifest"] and data["manifest"]["manifest_version"] >= 2.0:
				var manifest : Dictionary = data["manifest"]["manifest_data"]
				var info : Dictionary = manifest["mod_information"]
				var version : Dictionary = manifest["version"]
				mods[info["id"]] = {"name":info["name"],"version":{"major":version["version_major"],"minor":version["version_minor"],"bugfix":version["version_bugfix"]},"path":data["file_path"],"changelog":manifest["manifest_definitions"]["changelog_path"]}
		var last : Dictionary = {}
		if file.file_exists(folder + last_seen_file):
			file.open(folder + last_seen_file,File.READ)
			last = JSON.parse(file.get_as_text()).result
			file.close()
		var changes : Dictionary = {}
		for mod in mods:
			var has_changed:bool = false
			var data : Dictionary = mods[mod]
			if mod in last:
				if data["version"]["major"] != last[mod]["version"]["major"]:
					has_changed = true
				if data["version"]["minor"] != last[mod]["version"]["minor"]:
					has_changed = true
				if data["version"]["bugfix"] != last[mod]["version"]["bugfix"]:
					has_changed = true
			else:
				has_changed = true
			if has_changed:
				changes.merge({mod:data})
		return changes
	
	func __get_mod_versions(store = false,folder = "user://cache/.Mod_Menu_2_Cache/changelogs/",last_seen_file = "mods_from_last_launch.json",this_seen_file = "mods_from_this_launch.json") -> Dictionary:
		var mods : Dictionary = {}
		var all_mods : Dictionary = {}
		if not cached_mod_list.empty():
			all_mods = cached_mod_list["mods"]
		else:
			all_mods = __get_mod_data()["mods"]
		for mod in all_mods:
			var data : Dictionary = all_mods[mod]
			if data["manifest"]["has_manifest"] and data["manifest"]["manifest_version"] >= 2.0:
				var manifest : Dictionary = data["manifest"]["manifest_data"]
				var info : Dictionary = manifest["mod_information"]
				var version : Dictionary = manifest["version"]
				mods[info["id"]] = {"name":info["name"],"version":{"major":version["version_major"],"minor":version["version_minor"],"bugfix":version["version_bugfix"]}}
		if store:
			if not folder.ends_with("/"):
				folder = folder + "/"
			if last_seen_file.begins_with("/"):
				last_seen_file.lstrip("/")
			pointers.FolderAccess.__check_folder_exists(folder)
			if file.file_exists(folder + this_seen_file):
				file.open(folder + this_seen_file,File.READ)
				var lastData : Dictionary = JSON.parse(file.get_as_text()).result
				file.close()
				file.open(folder + last_seen_file,File.WRITE)
				file.store_string(JSON.print(lastData))
				file.close()
			file.open(folder + this_seen_file,File.WRITE)
			file.store_string(JSON.print(mods))
			file.close()
		return mods
	
	func __parse_changelogs(file_path):
#		var c:ConfigFile = ConfigFile.new()
#		c.load(file_path)
		
		file.open(file_path,File.READ)
		var text = file.get_as_text(true)
		file.close()
		var cv = {}
		
		var lastVer:String = ""
		for line in text.split("\n"):
			var noedge:String = line.strip_edges()
			if noedge.begins_with(";"):
				continue
			if noedge.begins_with("[") and noedge.ends_with("]"):
				var version = noedge.substr(1,noedge.length() - 2)
				if not version in cv:
					lastVer = version
					cv[version] = {}
				else:
					lastVer = ""
				continue
			if lastVer and noedge:
				var index:String = noedge.split("=")[0]
				var entry:String = noedge.substr(index.length() + 1)
				if entry.begins_with("\""):
					entry = entry.substr(1)
					if entry.ends_with("\""):
						entry = entry.substr(0,entry.length() - 1)
				cv[lastVer][index] = entry
		
		
		var changelog : Dictionary = {}
#		var versions : Array = c.get_sections()
		var versions : Array = cv.keys()
#		versions.resize(clamp(versions.size(),0,10))
		var spacing : String = "  "
		var spc = pointers.ConfigDriver.__get_value("ModMenu2","MODMENU2_CONFIG_GENERAL","changelog_spacing_size")
		if spc != "" or spc != null:
			spacing = spc
		for version in versions:
			changelog.merge({version:[]})
			var keys : Array = cv[version].keys()
			keys.sort_custom(self,"changelogKeySorter")
			keys = filterChangelogs(keys)
			
			for key in keys:
				var entry = str(cv[version][key])
				var spacer:String = ""
				for i in range(key.split(".").size() - 1):
					spacer += spacing
				changelog[version].append(spacer + entry)
		return changelog
	
	func changelogKeySorter(al:String,bl:String) -> bool:
		var aList:PoolStringArray = al.split(".")
		var bList:PoolStringArray = bl.split(".")
		var aSize:int = aList.size()
		var bSize:int = bList.size()
		var counter = aSize if aSize < bSize else bSize
		for i in range(counter):
			var a = aList[i]
			var b = bList[i]
			if a != b:
				return a < b
		return aSize < bSize
	
	func filterChangelogs(keys:Array) -> Array:
		if keys.size() > 1:
			var counter:int = 0
			var total:int = keys.size() - 1
			while counter < total:
				var al:String = keys[counter]
				var bl:String = keys[counter+1]
				var aList:PoolStringArray = al.split(".")
				var bList:PoolStringArray = bl.split(".")
				var aSize:int = aList.size()
				var bSize:int = bList.size()
				if (aSize == bSize):
					var aItem:String = aList[aSize - 1]
					var bItem:String = bList[bSize - 1]
					if int(bItem) > (int(aItem) + 1):
						keys.remove(counter + 1)
						total -= 1
				counter += 1
		return keys
	
	func __get_manifest_cache() -> Dictionary:
		return cached_manifests
	
	var modmain_file_list : Array = []
	
	func __get_modmain_files() -> Array:
		if modmain_file_list:
			return modmain_file_list.duplicate()
		var structure : Dictionary = pointers.FolderAccess.__get_folder_structure("res://",false,false)
		var dvs : Array = []
		if OS.has_feature("editor"):
			dvs = pointers.DataFormat.__get_script_variables_without_load("res://ModLoader.gd").get("addedMods",[])
		else:
			for r in __get_mod_files():
				var i : String = r.get_file().to_lower()
				if i.begins_with("modmain") and i.ends_with(".gd"):
					dvs.append(r)
		modmain_file_list = dvs
		return dvs.duplicate()
	
	var active_modlet_file_list : Array = []
	var all_modlet_file_list : Array = []
	var all_modlet_definitions : Dictionary = {}
	
	var cached_modlets : Dictionary = {}
	
	func __get_all_modlets(only_show_installed : bool = true,recache : bool = false) -> Dictionary:
		if cached_modlets:
			var modletCheck = pointers.ConfigDriver.__get_value("HevLib","modlets","seen_modlets")
			for modlet in modletCheck:
				if modletCheck[modlet] != cached_modlets[modlet]:
					recache = true
		if not cached_modlets or recache:
			if not all_modlet_file_list:
				var manifests = __get_manifest_files()
				var manifest_checks : Array = []
				for i in manifests:
					manifest_checks.append(i.to_lower())
				var allModFiles : Array = __get_mod_files()
				for r in allModFiles:
					var i : String = r.get_file().to_lower()
					if (i.begins_with("modmain") and i.ends_with(".gd")):
						var mr : String = r.get_base_dir().to_lower() + "/mod.manifest"
						if mr in manifest_checks:
							manifest_checks.erase(mr)
				var ov : Array = []
				for i in manifests:
					if i.to_lower() in manifest_checks:
						ov.append(i)
				ov.sort_custom(self,"sort_modlet_files")
				all_modlet_file_list = ov
			var modlets : Array = all_modlet_file_list.duplicate()
			var allowed_modlets = pointers.ConfigDriver.__get_value("HevLib","modlets","seen_modlets")
			if allowed_modlets == null:
				pointers.ConfigDriver.__store_value("HevLib","modlets","seen_modlets",{})
				allowed_modlets = {}
			active_modlet_file_list = []
			for mod in modlets:
				if not mod in allowed_modlets:
					allowed_modlets[mod] = true
				if allowed_modlets[mod]:
					active_modlet_file_list.append(mod)
			pointers.ConfigDriver.__store_value("HevLib","modlets","seen_modlets",allowed_modlets)
			cached_modlets = allowed_modlets
		var out : Dictionary = cached_modlets.duplicate(true)
		if only_show_installed:
			for mod in cached_modlets:
				if not mod in active_modlet_file_list:
					out.erase(mod)
		return out
	
	func sort_modlet_files(a:String,b:String):
		var aPrio:int = __parse_file_as_manifest(a)["manifest_definitions"]["modlet_priority"]
		var bPrio:int = __parse_file_as_manifest(b)["manifest_definitions"]["modlet_priority"]
		if aPrio != bPrio:
			return aPrio < bPrio
		if a != b:
			return a < b
		return false
	
	func __get_modlet_files() -> Array:
		__get_all_modlets()
		return active_modlet_file_list.duplicate()
	
	var cached_mod_files : Array = []
	
	func __get_mod_files():
		if cached_mod_files:
			return cached_mod_files.duplicate(true)
		var restrict_to_modmains : Array = []
		if OS.has_feature("editor"):
			var dvs : Array = pointers.DataFormat.__get_script_variables_without_load("res://ModLoader.gd").get("addedMods",[])
			for a in dvs:
				restrict_to_modmains.append(a.get_base_dir() + "/")
		var arr1 : Array = siftFolderStructureForModFiles(pointers.FolderAccess.__get_folder_structure("res://",false,false),"res://",restrict_to_modmains)
		var arr2:Array = []
		if OS.has_feature("editor"):
			var excludeDirs:Array = []
			for i in arr1:
				var r:String = i.get_file().to_lower()
				if r.begins_with("modmain") and r.ends_with(".gd"):
					var can : Script = load(i)
					if not can.can_instance():
						var vdir:String = i.get_base_dir()
						excludeDirs.append(vdir.to_lower())
						pointers.l("Excluding mod directoy %s due to malformatted mod main" % vdir,"pointers.ManifestV2")
			if excludeDirs:
				for file in arr1:
					var vr:String = file.get_base_dir().to_lower()
					if not vr in excludeDirs:
						arr2.append(file)
			else:
				arr2 = arr1
		else:
			arr2 = arr1
		cached_mod_files = arr2
		return cached_mod_files.duplicate(true)
	
	func siftFolderStructureForModFiles(structure:Dictionary,path:String = "res://",restricted_to_modmains : Array = []):
		var out : Array = []
		if restricted_to_modmains:
			var ev : Array = structure.keys()
			for i in range(ev.size()):
				ev[i] = ev[i].to_lower()
			for f in ev:
				if f.begins_with("modmain") and f.ends_with(".gd"):
					if not path in restricted_to_modmains:
						return []
		for i in structure:
			if i.ends_with("/"):
				out.append_array(siftFolderStructureForModFiles(structure[i],path + i,restricted_to_modmains))
			else:
				var f : String = i.to_lower()
				if (
					(
						f.begins_with("modmain")
						and 
						f.ends_with(".gd")
					)
					or 
					(
						f.begins_with("mod") 
						and 
						f.ends_with(".manifest")
					)
					or 
					(
						f.begins_with("icon")
						and
						(f.ends_with(".stex") or f.ends_with(".png"))
					)
				):
					out.append(path + i)
		return out
	
	var cached_manifest_files : Array = []
	
	func __get_manifest_files():
		if cached_manifest_files:
			return cached_manifest_files.duplicate()
		var ov : Array = []
		for r in __get_mod_files():
			var i : String = r.get_file().to_lower()
			if i.begins_with("mod") and i.ends_with(".manifest"):
				ov.append(r)
		cached_manifest_files = ov
		return cached_manifest_files.duplicate()
	
	var cached_icon_files : Array = []
	
	func __get_icon_files():
		if cached_icon_files:
			return cached_icon_files.duplicate()
		var ov : Array = []
		for r in __get_mod_files():
			var i : String = r.get_file().to_lower()
			if i.begins_with("icon") and (i.ends_with(".stex") or i.ends_with(".png")):
				ov.append(r)
		cached_icon_files = ov
		return cached_icon_files.duplicate()
	
	func __load_modlets(is_onready : bool):
		var modlet_manifests = __get_modlet_files()
		var scenes_to_reload : Array = []
		for modlet in modlet_manifests:
			var drivers = pointers.DriverManagement.__get_drivers_from_modmain_path(modlet)
			if "LOAD_RESOURCES.gd" in drivers:
				pointers.DataFormat.__loadDLC()
				var resources : Dictionary = drivers["LOAD_RESOURCES.gd"].get("LOAD_RESOURCES",{})
				if resources and typeof(resources) == TYPE_DICTIONARY:
					for resource in resources:
						var subdata : Dictionary = resources[resource]
						var load_type : String = subdata.get("load_type","").to_lower()
						var is_relative:bool = resource.begins_with("res://")
						if is_onready == subdata.get("onready",false):
							match load_type:
								"script":
									var path : String = resource if is_relative else (modlet.get_base_dir() + ("" if resource.begins_with("/") else "/") + resource)
									pointers.DataFormat.__override_script(path)
								"scene","resource":
									var path : String = resource if is_relative else (modlet.get_base_dir() + ("" if resource.begins_with("/") else "/") + resource)
									var orig_test : String = path.split(modlet.get_base_dir())[1]
									var old : String = subdata.get("original_path","res:/" + path.split(modlet.get_base_dir())[0])
									var old_relative:bool = old.begins_with("res://")
									var old_path : String = old if old_relative else ("res:/" + ("" if old.begins_with("/") else "/") + old)
									pointers.DataFormat.__replace_resource(path,old_path)
									if not old_path in scenes_to_reload:
										scenes_to_reload.append(old_path)
								"reload":
									var path : String = resource if is_relative else ("res:/" + ("" if resource.begins_with("/") else "/") + resource)
									pointers.DataFormat.__reload_scene(path)
				pointers.DataFormat.__loadDLC()
		return scenes_to_reload
	
	var disabledModletCache:Dictionary = {}
	
	func __get_disabled_modlets() -> Dictionary:
		if not disabledModletCache:
			var disabled:Dictionary = {}
			var all_modlets:Dictionary = __get_all_modlets(false)
			for modlet in all_modlets:
				if not all_modlets[modlet] and pointers.DataFormat.__file_exists(modlet):
					var mv:Dictionary = __parse_file_as_manifest(modlet)
					disabled.merge({modlet:mv.get("mod_information",{}).get("id","%s_MISSING_ID" % modlet)})
			disabledModletCache = disabled
		return disabledModletCache.duplicate(true)
	
	

class _NodeAccess:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	func _init(f):
		pointers = f
	
	func __get_all_children(node:Node, strip_supplied_node_from_array = false, return_only_paths = false, use_relative_paths = false):
		var children : Array = getAllChildren(node)
		if strip_supplied_node_from_array:
			children = strip_node(node, children)
		if return_only_paths:
			children = returnPaths(children, use_relative_paths, node)
		return children

	func getAllChildren(in_node:Node,arr : Array = []):
		arr.push_back(in_node)
		for child in in_node.get_children():
			arr = getAllChildren(child,arr)
		return arr

	func strip_node(in_node, arr):
		var paths : Array = []
		for m in arr:
			var selfPath : String = in_node.get_path()
			var modify:PoolStringArray = str(m.get_path()).split(selfPath)
			if modify[1] != "":
				paths.append(m)
		return paths

	func returnPaths(arr, relative, in_node):
		var parentPath : String = str(in_node.get_path())
		var paths : Array = []
		for m in arr:
			var path : String = m.get_path()
			paths.append(path)
		if relative:
			var rel : Array = []
			for i in paths:
				var ps : String = str(str(i).split(parentPath)[1])
				var tsu : String = ps.lstrip("/")
				rel.append(tsu)
			paths = rel
		return paths
	
	func __claim_child_ownership(node: Node):
		var children : Array = node.get_children()
		for child in children:
			setOwnership(child, node)

	func setOwnership(current_node: Node,set_owner_node: Node):
		current_node.set_owner(set_owner_node)
		if current_node.get_child_count() >= 1:
			var children : Array = current_node.get_children()
			for child in children:
				if not __is_instanced_from_scene(child.get_parent()):
					setOwnership(child, set_owner_node)

	func __is_instanced_from_scene(p_node):
		if not p_node.filename.empty():
			return true
		return false
	
	func __dynamic_crew_expander(folder_path: String = "user://cache/.HevLib_Cache/dynamic_crew_expander/", max_crew:int = 24) -> String:
		pointers.FolderAccess.__check_folder_exists(folder_path)
		var log_header : String = "TSCN Writer for dynamic crew handler: "
		
		var line_to_test : String = "DIALOG_DERELICT_SWITCH_CREW"
		
		var base:int = 24
		
		var static_line_1 : String = "[gd_scene load_steps=3 format=2]"
		var static_line_3 : String = "[ext_resource path=\"res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn\" type=\"PackedScene\" id=1]"
		var static_line_4 : String = "[ext_resource path=\"res://comms/ConversationPlayer.gd\" type=\"Script\" id=2]"
		var static_line_6 : String = "[node name=\"DIALOG_DERELICT_RANDOM_1\" instance=ExtResource( 1 )]"

		var dynamic_line_1 : String = "[node name=\"DIALOG_DERELICT_SWITCH_CREW|%s\" type=\"Node\" parent=\".\" index=\"%s\"]"
		var dynamic_line_2 : String = "script = ExtResource( 2 )"
		var dynamic_line_3 : String = "myLine = false"
		var dynamic_line_4 : String = "faceless = true"
		var dynamic_line_5 : String = "importChildren = NodePath(\"../DIALOG_DERELICT_GO_AND_BRING_IT\")"
		var dynamic_line_6 : String = "agenda = \"CREW/%s\""
		var dynamic_line_7 : String = "agendaNotSame = true"
		
		
		var test = load("res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn").instance()
		var children : Array = test.get_children()
		var names : Array = []
		for child in children:
			names.append(child.name)
		var maximum:int = 0
		for line in names:
			if line.begins_with(line_to_test):
				var spl:PoolStringArray = line.split("|")
				if int(spl[1]) > maximum:
					maximum = int(spl[1])
		var tester:int = maximum + 1
		if tester > base:
			base = tester
		
		
		if max_crew <= base:
			pointers.l(log_header + "desired expansion to [%s] is less than or equal to the currently expanded number of [%s]" % [max_crew,base],"pointers.NodeAccess")
			return ""
		else:
			var header : String = static_line_1 + "\n\n" + static_line_3 + "\n" + static_line_4 + "\n\n" + static_line_6 + "\n\n"
			
			var compacted_string : String = header
			
			while max_crew > base:
				
				var compact : String = dynamic_line_1 % [base,base + 4] + "\n" + dynamic_line_2 + "\n" + dynamic_line_3 + "\n" + dynamic_line_4 + "\n" + dynamic_line_5 + "\n" + dynamic_line_6 % base + "\n" + dynamic_line_7 + "\n\n"
				
				compacted_string = compacted_string + compact
				
				base += 1
			if not folder_path.ends_with("/"):
				folder_path = folder_path + "/"
			var save_file_path : String = folder_path + "dynamic_crew_x%s.tscn" % base
			pointers.DataFormat.__replace_scene(compacted_string,"res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn",save_file_path)
			
			return save_file_path
	
	
	func __remove_scripts(node):
		node.set_script(null)
		for obj in node.get_children():
			__remove_scripts(obj)
	
	func __exit(restart : bool = false):
		if restart:
			var pid = OS.execute(OS.get_executable_path(), OS.get_cmdline_args(), false)
		OS.kill(OS.get_process_id())
	
	
	

class _RingInfo:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	func _init(p):
		pointers = p
	
	const pixelToKm = 10000
	const map = preload("res://ring/ring-map.png")
	const veins = preload("res://ring/ring-veins.png")
	
	func __get_pixel_at(pos: Vector2) -> Color:
		var image = map.get_data()
		var size = image.get_size()
		var x = int(clamp(floor(pos.x / pixelToKm), 0, size.x - 1))
		var sy = int(size.y)
		var y = ((int(floor(pos.y / pixelToKm)) %sy) + sy) %sy
		var x1 = int(clamp(x + 1, 0, size.x - 1))
		var y1 = (y + 1) %int(size.y)
		
		if x <= 0:
			return Color(0, 0, 0, 0)
		
		image.lock()
		var p00 = image.get_pixel(x, y)
		var p10 = image.get_pixel(x1, y)
		var p11 = image.get_pixel(x1, y1)
		var p01 = image.get_pixel(x, y1)
		image.unlock()
		
		var cx = (pos.x - floor(pos.x / pixelToKm) * pixelToKm) / pixelToKm
		var cy = (pos.y - floor(pos.y / pixelToKm) * pixelToKm) / pixelToKm

		var pu = (p00 * (1 - cx) + p10 * (cx))
		var pd = (p01 * (1 - cx) + p11 * (cx))
		
		var pixel = pu * (1 - cy) + pd * (cy)
		return pixel
	
	func __get_vein_pixel_at(pos: Vector2) -> Color:
		var veinImage = veins.get_data()
		var veinSize = veinImage.get_size()
		var x = posmod(pos.x, veinSize.x)
		var y = posmod(pos.y, veinSize.y)
		var x1 = posmod(pos.x + 1, veinSize.x)
		var y1 = posmod(pos.y + 1, veinSize.y)
		
		veinImage.lock()
		var p00 = veinImage.get_pixel(x, y)
		var p10 = veinImage.get_pixel(x1, y)
		var p11 = veinImage.get_pixel(x1, y1)
		var p01 = veinImage.get_pixel(x, y1)
		veinImage.unlock()
		
		var cx = fposmod(pos.x, 1)
		var cy = fposmod(pos.y, 1)

		var pu = lerp(p00, p10, cx)
		var pd = lerp(p01, p11, cx)
		
		var pixel = lerp(pu, pd, cy)
		return pixel
	
	func __get_vein_at(pos: Vector2) -> String:
		var p1 = __get_vein_pixel_at(pos / 1861.0)
		var p2 = __get_vein_pixel_at(pos / - 2531.0)
		
		var values = [p1.r, p1.g, p1.b, p1.a, p2.r, p2.b, p2.g, p2.a]
			
		var total = 0
		for n in range(CurrentGame.traceMinerals.size()):
			var tm = CurrentGame.traceMinerals[n]
			values[n] = pow(values[n] / pow(CurrentGame.mineralPrices.get(tm, 1), 0.2), 4)
			total += values[n]
			
		var rnd = randf() * total
		var nr = 0
		for n in values:
			rnd -= n
			if rnd < 0:
				return CurrentGame.traceMinerals[nr]
			nr += 1
		
		return CurrentGame.traceMinerals[0]
	
	func get_chaos_at(pos):
		return __get_pixel_at(pos).r
	
	func get_raw_density_at(pos):
		return __get_pixel_at(pos).b
	



class _TimeAccess:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	func _init(p):
		pointers = p
	
	func __compare_dates(date, compare_to_this_date):
		var isDifferent:bool = false
		var difference : String = "newer"
		var splitOne:PoolStringArray = date.split("T")
		var splitTwo:PoolStringArray = compare_to_this_date.split("T")
		var dateOne:PoolStringArray = splitOne[0].split("-")
		var dateTwo:PoolStringArray = splitTwo[0].split("-")
		var timeOne:PoolStringArray = splitOne[1].split(":")
		var timeTwo:PoolStringArray = splitTwo[1].split(":")
		var concatOne : Array = [dateOne[0],dateOne[1],dateOne[2],timeOne[0],timeOne[1],timeOne[2]]
		var concatTwo : Array = [dateTwo[0],dateTwo[1],dateTwo[2],timeTwo[0],timeTwo[1],timeTwo[2]]
		var index:int = 0
		while index < 6:
			var compare1 = concatOne[index]
			var compare2 = concatTwo[index]
			if compare1 > compare2:
				isDifferent = true
				difference = "newer"
			if compare1 < compare2:
				isDifferent = true
				difference = "older"
			if compare1 == compare2:
				isDifferent = false
				difference = "equal"
			
			if isDifferent:
				return difference
			index += 1
		if index >= 6:
			return "equal"
	
	func __get_time_in_seconds(datetime_dict : Dictionary):
		var time : int = 0
		time += (datetime_dict.get("second",0))
		time += (datetime_dict.get("minute",0) * 60)
		time += (datetime_dict.get("hour",0) * 60 * 60)
		time += (datetime_dict.get("day",0) * 60 * 60 * 24)
		time += (datetime_dict.get("month",0) * 60 * 60 * 24 * 30)
		time += (datetime_dict.get("year",0) * 60 * 60 * 24 * 30 * 12)
		
		
		return time
	

class _Translations:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	func _init(c):
		pointers = c
	
	func __updateTL(path:String, delim:String = ",", fullLogging:bool = true):
		var fileName : String = path.split("/")[path.split("/").size() - 1]
		var folderName : String = path.split(fileName)[0]
		pointers.l("Adding translations from [%s] in [%s]" % [fileName, folderName],"pointers.Translations")
		var tlFile:File = File.new()
		tlFile.open(path, File.READ)
		var translations : Array = []
		var translationCount:int = 0
		var csvLine : PoolStringArray = tlFile.get_line().split(delim)
		if fullLogging:
			pointers.l("Adding translations as: %s" % csvLine,"pointers.Translations")
		for i in range(1, csvLine.size()):
			var translationObject := Translation.new()
			translationObject.locale = csvLine[i]
			translations.append(translationObject)
		while not tlFile.eof_reached():
			var line = tlFile.get_line()
			if line.begins_with("#"):
				continue
			csvLine = line.split(delim)
			var size:int = csvLine.size()
			if size > 1:
				if size > 2:
					var i:int = 0
					while i < size:
						if csvLine[i].ends_with("\\") and i < size:
							csvLine[i] = csvLine[i].rstrip("\\") + delim + csvLine[i + 1]
							csvLine.remove(i + 1)
							size -= 1
						i += 1
				var translationID : String = csvLine[0]
				for i in range(1, size):
					translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
				if fullLogging:
					pointers.l("Added translation: %s" % csvLine,"pointers.Translations")
				translationCount += 1
		tlFile.close()
		for translationObject in translations:
			TranslationServer.add_translation(translationObject)
		pointers.l("%s Translations Updated from @ [%s]" % [translationCount, fileName],"pointers.Translations")
	
	func __updateTL_from_dictionary(path:Dictionary, fullLogging:bool = true):
		pointers.l("Adding translations from dictionary","pointers.Translations")
		var translations : Array = []
		var translationCount:int = 0
		if fullLogging:
			pointers.l("Adding translations as: %s" % str(path.hash()),"pointers.Translations")
		if "file" in path:
			var file_paths : String = path["file"]
			for file in file_paths:
				var delim = file_paths[file]
				match typeof(delim):
					TYPE_STRING:
						var dict : Dictionary = __translation_file_to_dictionary(file,delim)
						__updateTL_from_dictionary(dict,fullLogging)
					TYPE_DICTIONARY:
						var string : String = delim.get("string","")
						var mod : String = delim.get("mod","")
						var section : String = delim.get("section","")
						var setting : String = delim.get("setting","")
						var invert:bool = delim.get("invert",false)
						var val = pointers.ConfigDriver.__get_value(mod,section,setting)
						var do = true
						if typeof(val) == TYPE_BOOL:
							do = val
						if invert:
							do = !do
						if do and string != "":
							var dict : Dictionary = __translation_file_to_dictionary(file,string)
							__updateTL_from_dictionary(dict,fullLogging)
						
			path.erase("file")
		for lang in path.keys():
			var translationObject := Translation.new()
			translationObject.locale = lang
			var translation_dict = path.get(lang)
			for key in translation_dict:
				var data = translation_dict.get(key)
				match typeof(data):
					TYPE_STRING:
						translationObject.add_message(key,data.c_unescape())
						if fullLogging:
							pointers.l("Added translation: %s" % key,"pointers.Translations")
					TYPE_DICTIONARY:
						var string = data.get("string","")
						var mod = data.get("mod","")
						var section = data.get("section","")
						var setting = data.get("setting","")
						var invert = data.get("invert",false)
						var val = pointers.ConfigDriver.__get_value(mod,section,setting)
						var do = true
						if typeof(val) == TYPE_BOOL:
							do = val
						if invert:
							do = !do
						if do and string != "":
							translationObject.add_message(key,string.c_unescape())
						if fullLogging:
							pointers.l("Added translation: %s" % key,"pointers.Translations")
			translationCount += 1
			
			translations.append(translationObject)
		for translationObject in translations:
			TranslationServer.add_translation(translationObject)
		pointers.l("%s Translations Updated" % [translationCount],"pointers.Translations")
	func __fetch_all_translation_objects(index) -> Array:
		var translations : Array = []
		while index >= 1:
			var obj = instance_from_id(index)
			index -= 1
			if obj == null:
				continue
			var data = obj.get_class()
			if not data == "Translation":
				continue
			translations.append(obj) # for future, see if obj.self works to get the node instead of a reference
		return translations
	
	func __translation_file_to_dictionary(path : String, delimiter : String = "|") -> Dictionary:
		if not Directory.new().file_exists(path):
			return {}
		var dictionary:Dictionary = {}
		var file:File = File.new()
		file.open(path,File.READ)
		var lines:PoolStringArray = file.get_as_text(true).split("\n")
		file.close()
		
		var lang_data:String = lines[0]
		var language_lines:PoolStringArray = lang_data.split(delimiter)
		if not language_lines[0] == "locale":
			return {}
		if language_lines.size() <= 1:
			return {}
		var languages:Array = []
		var lsize:int = language_lines.size()
		var lindex:int = 1
		while lindex < lsize:
			languages.append(language_lines[lindex])
			lindex += 1
		
		for lang in languages:
			var smdc:Dictionary = {lang:{}}
			dictionary.merge(smdc)
		var translation_count:int = 0
		var size:int = lines.size()
		var index:int = 1
		while index < size:
			var line:String = lines[index]
			if line == "":
				index += 1
				continue
			if line.begins_with("#"):
				continue
			var line_split:PoolStringArray = line.split(delimiter)
			var split_size:int = line_split.size()
			if split_size > 2:
				var i:int = 0
				while i < split_size:
					if line_split[i].ends_with("\\") and i < split_size:
						line_split[i] = line_split[i].rstrip("\\") + delimiter + line_split[i + 1]
						line_split.remove(i + 1)
						split_size -= 1
					i += 1
			if split_size == 1:
				index += 1
				continue
			if split_size - 1 < languages.size():
				index += 1
				continue
			var translation_string:String = line_split[0]
			var tlindex:int = 0
			while tlindex < languages.size():
				var lang:String = languages[tlindex]
				dictionary[lang].merge({translation_string:line_split[tlindex + 1]})
				tlindex += 1
			index += 1
			translation_count += 1
		return dictionary
	
	

class _WebTranslate:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	var pointers
	func _init(f):
		pointers = f
	
	func __webtranslate(URL: String, fallback: Array = [], file_check: String = ""):
		pointers.l("Fetching translations from %s" % URL,"pointers.WebTranslate")
		var HevLib = preload("res://HevLib/webtranslate/FetchGithubData.tscn").instance()
		var pms = Debug.get_node("/root")
		var tstamp = Time.get_datetime_string_from_system()
		var date = str(tstamp.split("T")[0])
		var time = str(tstamp.split("T")[1])
		var tSpl = time.split(":")
		var timeConcat = tSpl[0] + "-" + tSpl[1] + "-" + tSpl[2]
		var timestamp = "~" + date + "~" + timeConcat
		var nodes = pms.get_children()
		var names = []
		for node in nodes:
			var name = node.name
			if name.begins_with("FetchGithubData"):
				names.append(name)
		var nSize = names.size()
		
		
		pointers.l("attaching node @ FetchGithubData%s~%s" % [timestamp,str(nSize)],"pointers.WebTranslate")
		HevLib.name = "FetchGithubData" + timestamp + "~" + str(nSize)
		HevLib.URLFullStopReformat = URL
		HevLib.fallbackFiles = fallback
		
		HevLib.file_check = file_check
		pms.call_deferred("add_child",HevLib)
	
	func __webtranslate_reset(URL: String) -> bool:
		var urlSplit = str(URL).split("github.com/")[1]
		var dataSplit = urlSplit.split("/")
		var user = dataSplit[0]
		var repo = dataSplit[1]
		var folderConcat = user + "~_~" + repo
		var folderToDelete = "user://cache/.HevLib_Cache/WebTranslate/" + folderConcat
		pointers.l("deleting cache folder @ %s" % folderToDelete,"pointers.WebTranslate")
		var did = pointers.FolderAccess.__recursive_delete(folderToDelete)
		if did:
			return true
		else:
			return false
	
	func __webtranslate_reset_by_file_check(file_check: String) -> bool:
		var did = false
		var folder_to_delete = ""
		var cache = "user://cache/.HevLib_Cache/WebTranslate/"
		var dir = Directory.new()
		var files = pointers.FolderAccess.__fetch_folder_files(cache, true, true)
		for file in files:
			if not file.ends_with("/"):
				continue
			var cFiles = pointers.FolderAccess.__fetch_folder_files(file, false, true)
			for f in cFiles:
				if not f.ends_with(".file_check_cache"):
					continue
				var fo = File.new()
				fo.open(f,File.READ)
				var txt = fo.get_as_text()
				fo.close()
				if txt == file_check:
					folder_to_delete = file
				else:
					continue
		if not folder_to_delete == "":
			did = pointers.FolderAccess.__recursive_delete(folder_to_delete)
		return did
	
	func __webtranslate_timed(URL: String, MINUTES_DELAY: int, fallback: Array = [], file_check: String = ""):
		pointers.l("function 'webtranslate_timed' initiated, starting constant translation of [%s] with a delay of [%s] minutes" % [URL,MINUTES_DELAY],"pointers.WebTranslate")
		var variableNode = ModLoader.get_tree().get_root().get_node("/root/HevLib~Variables")
		var handleNode = preload("res://HevLib/webtranslate/WebtranslateTimerHandler.tscn").instance()
		handleNode.name = URL + Time.get_time_string_from_system()
		handleNode.URL = URL
		handleNode.MINUTES = MINUTES_DELAY
		handleNode.fallback = fallback
		handleNode.file_check = file_check
		variableNode.add_child(handleNode)
	
	
	
	
	
	

class _Zip:
	var scripts : Array = [
		
	]
	
	func get_class_documentation():
		return {
			"description":"",
			"methods":{
				"":{
					"description":"",
					"args":[
						
					],
					"return":[
						
					]
				},
			}
		}
	
	
	var dir = Directory.new()
	func __get_zip_content(path, stripFolder = false, lowerCase = false):
		var listOfNames = []
		var g = gdunzip.new()
		g.load(path)
		var fileList = gdunzip.files
		for m in fileList.keys():
			if stripFolder:
				var delim = m.split("/")[0] + "/"
				var s = m.split(delim)
				m = s[1]
			if lowerCase:
				m = m.to_lower()
			listOfNames.append(m)
		return listOfNames
	func __fetch_file_from_zip(path, cacheDir, desiredFiles):
		var listOfNames = []
		var g = gdunzip.new()
		g.load(path)
		var fileList = g.files
		for m in fileList.keys():
			var string = cacheDir + m
			if string.ends_with("/"):
				dir.make_dir_recursive(string)
			listOfNames.append(m)
		var modFolder = listOfNames[0]
		var savedFiles = []
		for d in desiredFiles:
			for F in listOfNames:
				var M = str(F).split(str(F).split("/")[0] + "/")[1]
				if str(M).to_lower() == str(d).to_lower():
					var fileToFetch = modFolder + d
					var saveDir = cacheDir + fileToFetch
					var data = g.uncompress(F).get_string_from_utf8()
					if data:
						var file = File.new()
						file.open(saveDir, File.WRITE)
						file.store_string(data)
						file.close()
						savedFiles.append(saveDir)
					else:
						savedFiles.append("")
		return savedFiles











