extends Node

static func get_stat_data(STAT: String) -> int:
	var achievements = Achivements.achivements
	var stat = achievements.get(STAT)
	
	
	return stat
