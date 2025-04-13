extends Node

func get_lib_variables():
	var varNode = ModLoader.get_node("/root/HevLib~Variables")
	var aData = varNode.AchievementData
	var aPercentData = varNode.AchievementPercentageStats
	return {"AchievementData":aData,"AchievementPercentageStats":aPercentData}
