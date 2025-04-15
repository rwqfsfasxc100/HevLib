extends Node

var developer_hint = {
	"__get_github_filesystem":[
		"Fetches a filesystem from github",
		"'URL' string is the desired Github repository URL",
		"'nodeToReturnTo' is the node where the data will be sent once fetched",
		" -> if behaviour is set to normal, or has a typo, requires a function with the name \"_github_filesystem_data(data)\" to handle the returned data (data variant can be whatever name you desire)",
		" -> returns an array of all files and their paths relative to the Github root",
		"'behaviour' string to set what the function outputs and requires as input (current options are 'normal' and 'version_check')",
		"'special_behaviour_data' can be any variant, dependant on what behaviour is set to",
		" -> setting behaviour to 'normal' does not require anything, and so can be left blank",
		" -> setting behavior to 'version_check' requires a string to check the version against that found in the Github's mod manifest or mod main"
	]
}

static func __get_github_filesystem(URL: String, nodeToReturnTo: Node, behaviour: String = "normal", special_behaviour_data = ""):
	var f = preload("res://HevLib/scenes/fetch_from_github/get_github_filesystem.gd").new()
	var s = f.get_github_filesystem(URL, nodeToReturnTo, behaviour, special_behaviour_data)
	
