extends Node

func get_github_filesystem(URL: String, nodeToReturnTo: Node, behaviour: String = "normal", special_behaviour_data = ""):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var CRoot = Tool.get_tree().get_root()
	var gitHubFS = preload("res://HevLib/scenes/fetch_from_github/fs/FetchGithubData.tscn").instance()
	gitHubFS.URL = URL
	gitHubFS.ActOnModData = behaviour
	gitHubFS.mod_version = special_behaviour_data
	gitHubFS.nodeToReturnTo = nodeToReturnTo
	gitHubFS.name = "git_filesystem_" + str(rng.randi_range(1, 32767))
	CRoot.call_deferred("add_child",gitHubFS)
	
