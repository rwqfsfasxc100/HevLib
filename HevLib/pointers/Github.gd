extends Node

var developer_hint = {
	"__get_github_filesystem":[
		"Fetches a filesystem from github",
		"'URL' string is the desired Github repository URL",
		"'node_to_return_to' is the node where the data will be sent once fetched",
		" -> if behaviour is set to normal, or has a typo, requires a function with the name \"_github_filesystem_data(data)\" to handle the returned data (data variant can be whatever name you desire)",
		" -> returns an array of all files and their paths relative to the Github root",
		"'behaviour' string to set what the function outputs and requires as input (current options are 'normal' and 'version_check')",
		"'special_behaviour_data' can be any variant, dependant on what behaviour is set to",
		" -> setting behaviour to 'normal' does not require anything, and so can be left blank",
		" -> setting behavior to 'version_check' requires a string to check the version against that found in the Github's mod manifest or mod main"
	],
	"__get_github_release":[
		"Downloads the latest release from a github",
		"3 required variant inputs, and 3 other optional variants",
		" -> URL - The repository's URL to fetch release data from",
		" -> folder - the folder to save the files to",
		" -> node_to_return_to - node that receives the _downloaded_zip(file, filepath) signal, which returns two variants - file being the filename, and filepath being the file's full path",
		" -> Optional get_pre_releases - bool to decide whether it should consider pre-releases as viable releases to download from",
		" -> Optional file_preference - string that lets you selectively choose the downloaded file type, currently supports 'any' for all filetypes, or 'zip' to only consider zip downloads",
		" -> Optional file_to_download - string that decides what order to choose the file, currently supports 'first' to get the first file in the list, or 'latest' to get the latest uploaded file"
	]
}

static func __get_github_filesystem(URL: String, node_to_return_to: Node, behaviour: String = "normal", special_behaviour_data = ""):
	var f = preload("res://HevLib/scenes/fetch_from_github/get_github_filesystem.gd").new()
	var s = f.get_github_filesystem(URL, node_to_return_to, behaviour, special_behaviour_data)
	

static func __get_github_release(URL: String, folder: String, node_to_return_to: Node, get_pre_releases: bool = false, file_preference: String = "any", file_to_download: String = "first"):
	var f = preload("res://HevLib/scenes/fetch_from_github/get_github_release.gd").new()
	var s = f.get_github_release(URL, folder, node_to_return_to, get_pre_releases, file_preference, file_to_download)
	
