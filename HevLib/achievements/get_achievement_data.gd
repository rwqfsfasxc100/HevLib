extends Node

static func get_achievement_data(achievementID: String) -> Dictionary:
	var currentAchievements = Achivements.achivements
	var playtimeStats = Achivements.playtimeStats
	var playtimeAchievements = Achivements.playtimeAchievements
	# each entry in this variable should be [achievement name, stat name, stat limit, other associated data]
	var playtimeAchAndData = []
	
	for p in playtimeAchievements:
		for o in playtimeStats:
			if p[0] == o[0]:
				playtimeAchAndData.append([p[2],o[1],p[1],p[0]])
	
	var statsWithAchievements = Achivements.statsWithAchievements
	for a in statsWithAchievements:
		var stat = a
		var ps = statsWithAchievements.get(a)
		for s in ps:
			var limit = s
			var achievement = ps.get(s)
			playtimeAchAndData.append([achievement,stat,limit])
	
	var annoyingAsFuckAchievements = {"DIVER_10":10,"DIVER_50":50,"DIVER_ENCKE":3000,"DIVER_DRAGONS":3005,"LEAF_2":2000,"LEAF_5":5000,"LEAF_20":20000,"PLAYSTYLE_MANUAL":900}
	for each in annoyingAsFuckAchievements:
		var prefix = each.split("_")[0]
		var limit = annoyingAsFuckAchievements.get(each)
		var stat = ""
		match prefix:
			"DIVER":
				stat = "maxDepth"
			"LEAF":
				stat = "leaf"
			"PLAYSTYLE":
				stat = "manual"
		playtimeAchAndData.append([each,stat,limit])
	
	var isUnlocked = false
	for ach in currentAchievements:
		
		
		if ach == achievementID:
		
		
			isUnlocked = true
	var statAssociation = []
	
	
	
	
	var currentStatData = []
	for each in playtimeAchAndData:
		if each[0] == achievementID:
			currentStatData = each
	if currentStatData.size() == 0:
		currentStatData = [achievementID,null,null,null]
	elif currentStatData.size() == 3:
		currentStatData = [currentStatData[0],currentStatData[1],currentStatData[2],null]
	var isRareVal = 0
	var rarity = Achivements.achievementRarity
	for r in rarity:
		if achievementID == r:
			isRareVal = rarity.get(r)
	var isRare = false
	if isRareVal == 1:
		isRare = true
	
	var hasSpoiler = false
	var spoiler = ["DISCOVER_PHAGE","DISCOVER_MOONLET","DISCOVER_FROZEN_BODY","DISCOVER_DESTROYED_HABITAT","DISCOVER_URANIUM","ESCAPE_VELOCITY","DISCOVER_ANARCHY","LEAF_20","PLAYSTYLE_B8BACK","STORY_TESLA","SHIP_CAT","TOUCH_SINGULARITY","PLAYSTYLE_CRAZYIVAN","LEVEL_TOP","STORY_BBW_DESTROYED","STORY_G4A_DESTROYED","STORY_LOTR_DESTROYED"]
	for m in spoiler:
		if m == achievementID:
			hasSpoiler = true
	
	var returnData = {"name":currentStatData[0],"isUnlocked":isUnlocked,"stat":currentStatData[1],"limit":currentStatData[2],"data":currentStatData[3],"rare":isRare,"spoiler":hasSpoiler}
	return returnData
