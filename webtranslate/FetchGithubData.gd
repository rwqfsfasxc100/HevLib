extends Node

var currentUrl = ""

var fallbackFiles = []

var user = ""
var repo = ""
var githubDataBaseURL = ""
var currentFile = ""

var URLFullStopReformat = ""

var MINUTES = 0.5

var fallbackFunc = ""

func _ready():
	fetch_github_data(URLFullStopReformat)

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
	
	Debug.l("HevLib WebTranslate: requesting Github files @ %s" % githubDataBaseURL)
	$FetchURLData.request(rURL)
	
func get_github_branch(branchToFetch):
	Debug.l("HevLib WebTranslate: fetching Github branch data @ %s" % branchToFetch)
	githubDataBaseURL = githubDataBaseURL + branchToFetch + "/"
	var URL = currentUrl + "/git/trees/main?recursive=1"
	$FetchBranchData.request(URL)


var pathToWebtranslate = ""
var indexFile = ""
var listOfFiles = []
var webTranslateFiles = []
var webtranslateFolderURL = ""
func sort_data(P):
	var treeData = P.get("tree")
	for m in treeData:
		if m.get("type") != "tree":
			var filePath = m.get("path")
			listOfFiles.append(filePath)
	for f in listOfFiles:
		var pmp = str(str(f).split("/")[str(f).split("/").size()-1])
		if pmp.to_lower() == "index.wt":
			pathToWebtranslate = f.split(pmp)[0]
			if str(pathToWebtranslate).split("/")[str(pathToWebtranslate).split("/").size() - 1] == "":
				pathToWebtranslate = str(pathToWebtranslate).substr(0,str(pathToWebtranslate).length()-1)
			
			indexFile = pmp
	if pathToWebtranslate != "":
		for s in listOfFiles:
			if str(s).begins_with(pathToWebtranslate):
				webTranslateFiles.append(str(s))
	var fullIndexPath = githubDataBaseURL + pathToWebtranslate + "/" + indexFile
	
	Debug.l("HevLib WebTranslate: fetching index file from @ %s" % fullIndexPath)
	$FetchIndex.request(fullIndexPath)

var specificPaths = []
var indexData
func index_handler(releasesContent):
	indexData = releasesContent
	var indexSplit = str(releasesContent).split("\n")
	var trueIndex = []
	var specificFiles = []
	for m in indexSplit:
		if m != null and m != "":
			trueIndex.append(m)
	if trueIndex.size() >= 2:
		var fileIndex = 1
		while fileIndex <= trueIndex.size()-1:
			specificFiles.append(trueIndex[fileIndex])
			fileIndex += 1
	for file in specificFiles:
		var pf = pathToWebtranslate + "/" + file
		specificPaths.append(pf)
	var spFiles = []
	if specificFiles.size() == 0:
		for file in webTranslateFiles:
			var spl = str(file).split("/")
			var pl = str(spl[spl.size()-1])
			if pl.to_lower() != "index.wt":
				spFiles.append(file)
	if spFiles.size() >= 1:
		specificPaths = spFiles
	fetchTranslations()


func fetchTranslations():
	if specificPaths.size() >= 1:
		var resetPaths = []
		var pp = specificPaths[0]
		var translationForFetching = githubDataBaseURL + pp
		currentFile = translationForFetching
		for f in specificPaths:
			if f != pp:
				resetPaths.append(f)
		specificPaths = resetPaths
		
		Debug.l("HevLib WebTranslate: fetching specific translations @ %s" % translationForFetching)
		$FetchFileData.request(translationForFetching)
		
	else:
		Debug.l("HevLib WebTranslate: no more translations, removing self node @ %s" % self.name)
		var children = get_children()
		for child in children:
			self.remove_child(child)
		self.remove_and_skip()

func on_timeout():
	
	if not fallbackFiles == []:
		for file in fallbackFiles and fallbackFiles.size() >= 1:
			var Translations = preload("res://HevLib/pointers/Translations.gd").new()
			var type = file.typeof()
			if type == TYPE_STRING:
				Translations.__updateTL(file, "|", false)
			elif type == TYPE_ARRAY:
				Translations.__updateTL(file[0],file[1], false)
		
