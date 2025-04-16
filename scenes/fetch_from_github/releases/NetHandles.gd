extends Node

var releases_URL = ""
var folder = ""
var nodeToReturnTo
var get_pre_releases = false
var file_preference = "any"
var file_to_download = "first"

func _ready():
	if not releases_URL == "":
		var urlSplitByGithub = releases_URL.split("https://github.com/")
		var urlSplitByReleases = urlSplitByGithub[1].split("/releases")
		var githubApiURL = "https://api.github.com/repos/" + urlSplitByReleases[0] + "/releases"
		$ReleasesURLHandler.get_pre_releases = get_pre_releases
		$ReleasesURLHandler.folder = folder
		$ZipDownloadHandler.filePath = folder
		$ZipDownloadHandler.nodeToReturnTo = nodeToReturnTo
		$ReleasesURLHandler.file_preference = file_preference
		$ReleasesURLHandler.file_to_download = file_to_download
		$ReleasesURLHandler.request(githubApiURL)
	
