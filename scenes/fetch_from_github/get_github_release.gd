extends Node

func get_github_release(URL: String, folder: String, node_to_return_to: Node, get_pre_releases: bool = false, file_preference: String = "any", file_to_download: String = "first"):
	var cancel = false
	if node_to_return_to == null or (not node_to_return_to is Node):
		cancel = true
		var e = "HevLib Github Release Downloader: ERROR! Provided node [%s] either does not exist or is not of [Node] type." % str(node_to_return_to)
		Debug.l(e)
		printerr(e)
	if not node_to_return_to.has_method("_downloaded_zip"):
		cancel = true
		var e = "HevLib Github Release Downloader: ERROR! Provided node [%s] does not have the method [_downloaded_zip]" % str(node_to_return_to)
		Debug.l(e)
		printerr(e)
	if cancel:
		Tool.deferCallInPhysics(Tool,"remove",[self])
		return
	var CRoot = Tool.get_tree().get_root()
	var gitHubFS = preload("res://HevLib/scenes/fetch_from_github/releases/NetHandles.tscn").instance()
	if not node_to_return_to.has_method("_get_github_progress"):
		gitHubFS.state_progress = false
		Debug.l("HevLib Github Release Downloader: NOTICE! Provided node [%s] does not have the method [_get_github_progress]. No download progress will be reported." % str(node_to_return_to))
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	gitHubFS.releases_URL = URL
	gitHubFS.folder = folder
	gitHubFS.get_pre_releases = get_pre_releases
	gitHubFS.file_preference = file_preference
	gitHubFS.file_to_download = file_to_download
	gitHubFS.nodeToReturnTo = node_to_return_to
	gitHubFS.name = "git_release_" + str(rng.randi_range(1, 32767))
	CRoot.call_deferred("add_child",gitHubFS)
	
