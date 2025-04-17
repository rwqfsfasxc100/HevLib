extends Node

func get_github_release(URL: String, folder: String, node_to_return_to: Node, get_pre_releases: bool = false, file_preference: String = "any", file_to_download: String = "first"):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var CRoot = Tool.get_tree().get_root()
	var gitHubFS = preload("res://HevLib/scenes/fetch_from_github/releases/NetHandles.tscn").instance()
	gitHubFS.releases_URL = URL
	gitHubFS.folder = folder
	gitHubFS.get_pre_releases = get_pre_releases
	gitHubFS.file_preference = file_preference
	gitHubFS.file_to_download = file_to_download
	gitHubFS.nodeToReturnTo = node_to_return_to
	gitHubFS.name = "git_release_" + str(rng.randi_range(1, 32767))
	CRoot.call_deferred("add_child",gitHubFS)
	
