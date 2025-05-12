extends Node

var areModsEnabled = true

var addedMods = [
		"res://ModMenu/ModMain.gd",
		"res://HevLib/ModMain.gd",
		"res://No Simulation Hex/ModMain.gd",
		"res://Remove Ring Restrictions/ModMain.gd",
		"res://RingActivity/ModMain.gd",
#		"res://DerelictDelights/ModMain.gd",
#		"res://IndustriesOfEnceladusRevamp/ModMain.gd",
#		"res://Better Recon Drones/ModMain.gd",
#		"res://NTCED Parts Pack/ModMain.gd",
#		"res://SaveEdit/ModMain.gd",
#		"res://WikiEventTest/ModMain.gd",
#		"res://AutoTurret/ModMain.gd",
#		"res://LumaEdge/ModMain.gd",
#		"res://NDCI-mk2/ModMain.gd",
#		"res://Dwarf Crew/ModMain.gd",
#		"res://Controlling/ModMain.gd",
#		"res://EventDriver/ModMain.gd",
#		"res://MoreMinerals/ModMain.gd",
#		"res://PilotZoom/ModMain.gd",
#		"res://No Crew Portraits/ModMain.gd",
#		"res://Nothing Slider/ModMain.gd",
#		"res://RapidSynchro/ModMain.gd",
		"res://PilotableCompanions/ModMain.gd",
		"res://OCPRacingAP/ModMain.gd",
		"res://DeKanban/ModMain.gd",
	]

const is_debugged = true

func _init():
	for arg in OS.get_cmdline_args():
		if arg == "--enable-mods":
			areModsEnabled = true

	if not areModsEnabled:
		return 

	Debug.l("ModLoader: Loading mods...")
	_loadMods()
	Debug.l("ModLoader: Done loading mods.")

	Debug.l("ModLoader: Initializing mods...")
	_initMods()
	Debug.l("ModLoader: Done initializing mods.")


var _modZipFiles = []

func _loadMods():
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	var modPathPrefix = gameInstallDirectory.plus_file("mods")

	var dir = Directory.new()
	if dir.open(modPathPrefix) != OK:
		Debug.l("ModLoader: Can't open mod folder %s." % modPathPrefix)
		return 
	if dir.list_dir_begin() != OK:
		Debug.l("ModLoader: Can't read mod folder %s." % modPathPrefix)
		return 

	while true:
		var fileName = dir.get_next()
		if fileName == "":
			break
		if dir.current_is_dir():
			continue
		var modFSPath = modPathPrefix.plus_file(fileName)
		var modGlobalPath = ProjectSettings.globalize_path(modFSPath)
		if not ProjectSettings.load_resource_pack(modGlobalPath, true):
			Debug.l("ModLoader: %s failed to load." % fileName)
			continue
		_modZipFiles.append(modFSPath)
		Debug.l("ModLoader: %s loaded." % fileName)
	dir.list_dir_end()




var mod_list = {}
func _initMods():
	var initScripts = []
	for modFSPath in _modZipFiles:
		var gdunzip = load("res://vendor/gdunzip.gd").new()
		gdunzip.load(modFSPath)
		for modEntryPath in gdunzip.files:
			var modEntryName = modEntryPath.get_file().to_lower()
			if modEntryName.begins_with("modmain") and modEntryName.ends_with(".gd"):
				var modGlobalPath = "res://" + modEntryPath
				Debug.l("ModLoader: Loading %s" % modGlobalPath)
				var packedScript = ResourceLoader.load(modGlobalPath)
				var zipName = modFSPath.split("/")[modFSPath.split("/").size() - 1]
				var modName = packedScript.get_script_constant_map().get("MOD_NAME",zipName)
				var modVersion = packedScript.get_script_constant_map().get("MOD_VERSION",[1,0,0])
				mod_list.merge({modGlobalPath:[modName,modVersion, zipName]})
				initScripts.append(packedScript)

	
	for m in addedMods:
		var packedScript = ResourceLoader.load(m)
		initScripts.append(packedScript)

	initScripts.sort_custom(self, "_compareScriptPriority")

	for packedScript in initScripts:
		Debug.l("ModLoader: Running %s" % packedScript.resource_path)
		var scriptInstance = packedScript.new(self)
		add_child(scriptInstance)


func _compareScriptPriority(a, b):
	var aPrio = a.get_script_constant_map().get("MOD_PRIORITY", 0)
	var bPrio = b.get_script_constant_map().get("MOD_PRIORITY", 0)
	if aPrio != bPrio:
		return aPrio < bPrio

	
	var aPath = a.resource_path
	var bPath = b.resource_path
	if aPath != bPath:
		return aPath < bPath

	return false


func installScriptExtension(childScriptPath:String):
	var childScript = ResourceLoader.load(childScriptPath)

	
	
	
	
	
	
	
	childScript.new()

	var parentScript = childScript.get_base_script()
	var parentScriptPath = parentScript.resource_path
	Debug.l("ModLoader: Installing script extension: %s <- %s" % [parentScriptPath, childScriptPath])
	childScript.take_over_path(parentScriptPath)


func addTranslationsFromCSV(csvPath:String):
	var translationCsv = File.new()
	translationCsv.open(csvPath, File.READ)
	var TranslationParsedCsv = {}

	var translations = []

	
	var csvLine = translationCsv.get_csv_line()
	for i in range(1, csvLine.size()):
		var translationObject = Translation.new()
		translationObject.locale = csvLine[i]
		translations.append(translationObject)

	
	while not translationCsv.eof_reached():
		csvLine = translationCsv.get_csv_line()
		if csvLine.size() == 1 and csvLine[0] == "":
			break
		var translationID = csvLine[0]
		for i in range(1, csvLine.size()):
			translations[i - 1].add_message(translationID, csvLine[i])

	translationCsv.close()

	
	for translationObject in translations:
		TranslationServer.add_translation(translationObject)


func appendNodeInScene(modifiedScene, nodeName:String = "", nodeParent = null, instancePath:String = "", isVisible:bool = true):
	var newNode
	if instancePath != "":
		newNode = load(instancePath).instance()
	else :
		newNode = Node.instance()
	if nodeName != "":
		newNode.name = nodeName
	if isVisible == false:
		newNode.visible = false
	if nodeParent != null:
		var tmpNode = modifiedScene.get_node(nodeParent)
		tmpNode.add_child(newNode)
		newNode.set_owner(modifiedScene)
	else :
		modifiedScene.add_child(newNode)
		newNode.set_owner(modifiedScene)


var _savedObjects = []

func saveScene(modifiedScene, scenePath:String):
	var packed_scene = PackedScene.new()
	packed_scene.pack(modifiedScene)
	packed_scene.take_over_path(scenePath)
	_savedObjects.append(packed_scene)
