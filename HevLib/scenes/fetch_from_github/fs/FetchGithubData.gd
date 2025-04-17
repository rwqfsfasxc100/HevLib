extends Node

var currentUrl = ""

var fallbackFiles = []

var user = ""
var repo = ""
var githubDataBaseURL = ""
var currentFile = ""

var URL = ""
var ActOnModData = ""
var mod_version = ""
var nodeToReturnTo

var compared_version = ""
func _ready():
	if ActOnModData and mod_version == "":
		mod_version = "unknown"
	if not URL == null and not nodeToReturnTo == null:
		fetch_github_data(URL)

func fetch_github_data(URL):
	var urlSpl = str(URL).split("://")[1]
	var uSl = str(urlSpl).split("github.com/")
	var strSpl = uSl[1]
	var uulo = strSpl.split("/")[0]
	var uilo = strSpl.split("/")[1]
	URL = "https://github.com/" + uulo + "/" + uilo
#	if str(URL).split("/")[str(URL).split("/").size() - 1] == "":
#		URL = str(URL).substr(0,str(URL).length()-1)
	var rURL = str("https://api.github.com/repos/" + str(URL).split("https://github.com/")[1])
	
	currentUrl = rURL
	var urlSplit = rURL.split("/")
	user = rURL.split("/")[urlSplit.size()-2]
	repo = rURL.split("/")[urlSplit.size()-1]
	githubDataBaseURL = "https://raw.githubusercontent.com/" + user + "/" + repo + "/refs/heads/"
	
	Debug.l("HevLib Github FS Fetch: requesting Github files @ %s" % githubDataBaseURL)
	$FetchURLData.request(rURL)
	
func get_github_branch(branchToFetch):
	Debug.l("HevLib Github FS Fetch: fetching Github branch data @ %s" % branchToFetch)
	githubDataBaseURL = githubDataBaseURL + branchToFetch + "/"
	var URL = currentUrl + "/git/trees/main?recursive=1"
	$FetchBranchData.request(URL)


var pathToModMain = ""
var modMainFile = ""
var modManifestPath = ""
var modManifestFile = ""
var listOfFiles = []
func sort_data(P):
	var treeData = P.get("tree")
	for m in treeData:
		if m.get("type") != "tree":
			var filePath = m.get("path")
			listOfFiles.append(filePath)
	match ActOnModData:
		"normal":
			nodeToReturnTo._github_filesystem_data(listOfFiles)
		"version_check":
			version_check()
		_:
			nodeToReturnTo._github_filesystem_data(listOfFiles)
	
	
func version_check():
	for f in listOfFiles:
		var pmp = str(str(f).split("/")[str(f).split("/").size()-1])
		if pmp.to_lower() == "mod.manifest":
			modManifestPath = f.split(pmp)[0]
			if str(modManifestPath).split("/")[str(modManifestPath).split("/").size() - 1] == "":
				modManifestPath = str(modManifestPath).substr(0,str(modManifestPath).length()-1)
			
			modManifestFile = pmp
		if pmp.to_lower() == "modmain.gd":
			pathToModMain = f.split(pmp)[0]
			if str(pathToModMain).split("/")[str(pathToModMain).split("/").size() - 1] == "":
				pathToModMain = str(pathToModMain).substr(0,str(pathToModMain).length()-1)
			
			modMainFile = pmp
	if modManifestFile != "":
		var modManifestFull = githubDataBaseURL + modManifestPath + "/" + modManifestFile
		$FetchModManifestData.request(modManifestFull)
		
	elif modMainFile != "":
		var modMainFull = githubDataBaseURL + pathToModMain + "/" + modMainFile
		$FetchModMainData.request(modMainFull)
	

func handleVersionCheck():
	var do_update = false
	var compared_split = compared_version.split(".")
	var current_split = mod_version.split(".")
	var handleIdentical = false
	if current_split.size() == compared_split.size():
		handleIdentical = true
	if handleIdentical:
		var currentSmaller = false
		if current_split.size() > compared_split.size():
			currentSmaller = true
		if currentSmaller:
			var indexSize = current_split.size()
			var index = 0
			while index < indexSize:
				if current_split[index] < compared_split[index]:
					do_update = true
				index += 1
		else:
			var indexSize = compared_split.size()
			var index = 0
			while index < indexSize:
				if current_split[index] < compared_split[index]:
					do_update = true
				index += 1
	elif (compared_split.size() or current_split.size()) == 1:
		if compared_split[0] == "unknown" and current_split[0] != "unknown":
			do_update = false
		elif current_split[0] == "unknown" and compared_split[0] != "unknown":
			do_update = true
		elif int(current_split[0]) < int(compared_split[0]):
			do_update = true
		else:
			do_update = false
	else:
		do_update = false
	var update_data = false
	if do_update:
		update_data = [compared_version, mod_version]
	nodeToReturnTo._on_update_completed(update_data)
	
	
	
func on_timeout():
	
	if not fallbackFiles == []:
		for file in fallbackFiles and fallbackFiles.size() >= 1:
			var Translations = preload("res://HevLib/pointers/Translations.gd").new()
			Translations.__updateTL(file)
		
