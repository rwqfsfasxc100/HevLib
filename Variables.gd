extends Node

export var AchievementData = []
export var AchievementPercentageStats = []

export var ScreenHeight = 1280
export var ScreenWidth = 720

func _ready():
	load_variables()

func _process(delta):
	ScreenWidth = Settings.maxScreenScale.x
	ScreenHeight = Settings.maxScreenScale.y
	if OS.get_name() == "Windows":
		ScreenHeight -= 1

func load_variables():
	AchievementData = get_current_achievements()
	getAchievementStats()

# Fetches and returns data from the achievement file
# Returns a dictionary with four keys:
# allAchievements is an array of names of all achievements currently in-game
# unlockedAchievements is an array of names of all achievements currently unlocked in the achievements file
# lockedAchievements is the inverse, listing the names of all locked achievements
# stats are the names of all the current stats tracked, all with the stat: prefix
func get_current_achievements() -> Dictionary:
	var f = load("res://HevLib/achievements/get_current_achievements.gd")
	var s = f.get_current_achievements()
	return s

# Grabs the current achievement completion percentages from steam
# Returns an array of arrays when finished, each child array formatted with [NAME, PERCENT]
func getAchievementStats():
	var StatFetch = preload("res://HevLib/achievements/StatFetch.tscn").instance()
	var pms = ModLoader.get_node("/root")
	pms.call_deferred("add_child",StatFetch)
	
