extends Node

static func get_current_achievements():
	var unlockedAchievements = []
	var lockedAchievements = []
	var allAchievements = []
	var stats = []
	# Fetches data from the achievements file
	var achievementData = Achivements.achivements
	# gets the rarity dict
	# This is used to compare the achievements file to, as the achievements file only contains unlocked achievements and stats that are above zero
	var rarity = Achivements.achievementRarity
	for m in achievementData:
		if not str(m).begins_with("stat:"):
			unlockedAchievements.append(m)
		else:
			stats.append(m)
	for m in rarity.keys():
		allAchievements.append(m)
	if unlockedAchievements.size() != allAchievements.size():
		for f in allAchievements:
			if not unlockedAchievements.has(f):
				lockedAchievements.append(f)
	var ccDictionary = {"allAchievements":allAchievements,"unlockedAchievements":unlockedAchievements,"lockedAchievements":lockedAchievements,"stats":stats}
	return ccDictionary
