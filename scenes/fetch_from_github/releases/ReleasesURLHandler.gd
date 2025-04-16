extends HTTPRequest

var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd").new()

var folder = ""
var get_pre_releases = false
var file_preference = "any" # Accepts "any" or "zip"
var file_to_download = "first" # Accepts "first", "all" or "latest"

var urlToFetch = []

func _on_release_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var releasesContent
	var TimeAccess = preload("res://HevLib/pointers/TimeAccess.gd").new()
	var assetURLs = []
	if not json.result == null:
		releasesContent = json.result
	var cycle = 0
	if not releasesContent == null:
		for n in releasesContent:
			if cycle == 0:
				if not checkIfAcceptable(n):
					pass
				else:
					for asset in n["assets"]:
						var assetURL = asset["browser_download_url"]
						var releaseDate = asset["updated_at"].split("Z")[0]
					
						assetURLs.append([assetURL, releaseDate])
					var githubTag = n["tag_name"]
					cycle += 1
		for item in assetURLs:
			var acceptable = true
			if file_preference == "zip":
				if not item[0].ends_with(".zip"):
					acceptable = false
			if file_to_download == "latest":
				var isLatest = true
				for item2 in assetURLs:
					var date = item2[1]
					var comparison = TimeAccess.__compare_dates(item[1],date)
					if comparison == "older":
						isLatest = false
				if not isLatest:
					acceptable = false
			if file_to_download == "all":
				pass  # IMPLEMENT HANDLING FOR "ALL" TAG
			if acceptable:
				urlToFetch.append(item[0])
				break
		
		if urlToFetch.size() == 1:
			downloadZip(urlToFetch[0], folder)
		elif urlToFetch.size() >= 2:
			pass # IMPLEMENT HANDLING FOR "ALL" TAG

func checkIfAcceptable(n):
	if n["draft"]:
		return false
	if n["prerelease"]:
		if get_pre_releases:
			return true
		else:
			return false
	else:
		return true


func downloadZip(url, folder):
	if not folder.ends_with("/"):
		folder = folder + "/"
	var check = FolderAccess.__check_folder_exists(folder)
	if not check:
		return
	var zipName = url.split("/")[url.split("/").size() - 1]
	
	var dir = Directory.new()
	dir.open(folder)
	var does = dir.file_exists(zipName)
	
	if does:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rnd = rng.randi_range(1, 32767)
		
		zipName = str(rnd) + "_" + zipName
	get_parent().get_node("ZipDownloadHandler").set_download_file(folder + zipName)
	get_parent().get_node("ZipDownloadHandler").request(url)
	
