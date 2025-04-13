extends Node

var developer_hint = {
	"__get_achievement_data":[
		"Gets the data of a provided achievement by it's ID",
		"Returns a dictionary with 7 keys:",
		"name = the achievement's ID for convenience",
		"isUnlocked = boolean for whether the achievement is unlocked or not",
		"stat = associated stat name, w/o the stat: prefix",
		"limit = the stat's unlocking threshhold",
		"data = any additional data that might be useful to provide. ",
		" -> currently only provides the ship/equipment names of playtime achievements in untranslated form",
		"rare = based on whether the game considers an achievement rare",
		"spoiler = whether the achievement is considered a spoilered achievement on steam.",
		" -> manually inputted data, so may be missing data in the days following an update that adds achievements"
		],
	"__get_stat_data":[
		"Gets the numerical value of the provided stat"
		]
}

static func __get_achievement_data(achievementID: String) -> Dictionary:
	var f = load("res://HevLib/achievements/get_achievement_data.gd")
	var s = f.get_achievement_data(achievementID)
	return s


static func __get_stat_data(stat: String) -> int:
	var f = load("res://HevLib/achievements/get_stat_data.gd")
	var s = f.get_stat_data(stat)
	return s
