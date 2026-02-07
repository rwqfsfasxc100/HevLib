extends Node

class Achievements:
	var scripts = [
		preload("res://HevLib/achievements/get_achievement_data.gd"),
		preload("res://HevLib/achievements/get_stat_data.gd"),
	]
	func __get_achievement_data(achievementID: String) -> Dictionary:
		return scripts[0].get_achievement_data(achievementID)
	
	func __get_stat_data(stat: String) -> int:
		return scripts[1].get_stat_data(stat)
	

