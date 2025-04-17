extends HTTPRequest

func _ready():
	self.request("https://api.steampowered.com/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/?gameid=846030")
	


func _on_StatFetch_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var releasesContent
	var data
	if not json.result == null:
		releasesContent = json.result
	if not releasesContent == null:
		data = releasesContent.get("achievementpercentages").get("achievements")
	var aData = []
	if not data == null:
		for dic in data:
			aData.append([dic.get("name"),dic.get("percent")])
		
		
	get_parent().get_node("/root/HevLib~Variables").AchievementPercentageStats = aData
	self.remove_and_skip()
