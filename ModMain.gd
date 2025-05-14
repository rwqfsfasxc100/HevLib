extends Node

const MOD_PRIORITY = INF
const MOD_NAME = "HevLib"
const MOD_VERSION = "1.5.1"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 5
const MOD_VERSION_BUGFIX = 1
const MOD_VERSION_METADATA = ""
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []
var modConfig = {}

# Required for the addEquipmentSlot() function
var ADD_EQUIPMENT_SLOTS = []

# Required for the addEquipmentItem() function
var ADD_EQUIPMENT_ITEMS = []

# Required if any additional tags are going to be added. Only additive tags should be placed here.
var EQUIPMENT_TAGS = {}

# Additional tags that you'd like to add to any slots, pre-existing or new
var SLOT_TAGS = {}

func _init(modLoader = ModLoader):
	l("Initializing DLC")
	loadDLC()
	loadSettings()
	installScriptExtension("events/TheRing.gd")
	replaceScene("scenes/scene_replacements/TheRing.tscn", "res://story/TheRing.tscn")
func _ready():
	l("Readying")
	SLOT_TAGS = tags
	
	# Commented out examples for adding equipment and slots 
#	addEquipmentSlot({"system_slot":"slot.new", "slot_node_name":"NewSlot","slot_display_name":"SLOT_DATA_DRIVEN_SLOT_TEST"})
#	addEquipmentItem({"system":"SYSTEM_TEST", "slots":["NewSlot"]})
#	EQUIPMENT_TAGS = new_equipment_tags
#	addEquipmentSlot({"system_slot":"weaponSlot.turretLeft.type","slot_node_name":"TurretLeft","slot_display_name":"SLOT_TURRET_LEFT"})
#	addEquipmentSlot({"system_slot":"weaponSlot.turretRight.type","slot_node_name":"TurretRight","slot_display_name":"SLOT_TURRET_RIGHT"})
#	SLOT_TAGS.merge(new_tags)
	installScriptExtension("scenes/equipment/UpgradeGroup.gd")
	installScriptExtension("scenes/equipment/hardpoints/EquipmentItemTemplate.gd")
	var WebTranslate = preload("res://HevLib/pointers/WebTranslate.gd")
	WebTranslate.__webtranslate("https://github.com/rwqfsfasxc100/HevLib",[[modPath + "i18n/en.txt", "|"]])
	replaceScene("scenes/scene_replacements/MouseLayer.tscn", "res://menu/MouseLayer.tscn")
	if ModLoader.is_debugged:
		replaceScene("scenes/scene_replacements/TitleScreen.tscn", "res://TitleScreen.tscn")
	replaceScene("scenes/equipment/Upgrades.tscn", "res://enceladus/Upgrades.tscn")
	var NodeNew = Node.new()
	NodeNew.set_script(load("res://HevLib/scripts/Variables.gd"))
	NodeNew.name = "HevLib~Variables"
	var Gamespace_Canvas = load("res://HevLib/ui/core_scenes/_HevLib_Gamespace_Canvas.tscn").instance()
	var mouse = load("res://HevLib/scenes/scene_replacements/MouseLayer.tscn").instance()
	var CRoot = get_tree().get_root()
	CRoot.call_deferred("add_child",NodeNew)
	CRoot.call_deferred("add_child",Gamespace_Canvas)
	CRoot.call_deferred("add_child",mouse)
	loadTranslationsFromCache()
	replaceScene("scenes/scene_replacements/Game.tscn", "res://Game.tscn")
	var dir = Directory.new()
	dir.make_dir_recursive("user://cache/.HevLib_Cache/")
	var file = File.new()
	file.open("user://cache/.HevLib_Cache/library_documentation.json", File.WRITE)
	file.store_string(load("res://HevLib/pointers/HevLib.gd").__get_library_functionality(true))
	file.close()
	var keybind_interrupt = load("res://HevLib/scenes/keymapping/keybind_interrupt.tscn").instance()
	CRoot.call_deferred("add_child",keybind_interrupt)
	l("Ready")
func loadTranslationsFromCache():
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd").new()
	var WebTranslateCache = "user://cache/.HevLib_Cache/WebTranslate/"
	FolderAccess.__check_folder_exists(WebTranslateCache)
	var cacheContent = FolderAccess.__fetch_folder_files(WebTranslateCache, true)
	for folder in cacheContent:
		var folderPath = WebTranslateCache + folder
		var files = FolderAccess.__fetch_folder_files(folderPath)
		for file in files:
			var filePath = str(folderPath + file)
			var ffile = str(file)
			var dm = ffile.split("--")[1]
			var does = true
			if str(dm).ends_with("]"):
				does = false
			if does:
				var vm = dm.split("-~-")
				var mv = PoolByteArray()
				for itm in vm:
					mv.append(int(itm))
				var delim = mv.get_string_from_utf8()
				updateTL(filePath,delim,false,false)
			else:
				var dir = Directory.new()
				dir.remove(filePath)
func updateTL(path:String, delim:String = ",", useRelativePath:bool = true, fullLogging:bool = true):
	if useRelativePath:
		path = str(modPath + path)
	var fileName = path.split("/")[path.split("/").size() - 1]
	var folderName = path.split(fileName)[0]
	l("Adding translations from [%s] in [%s]" % [fileName, folderName])
	var tlFile:File = File.new()
	tlFile.open(path, File.READ)
	var translations := []
	var translationCount = 0
	var csvLine := tlFile.get_line().split(delim)
	if fullLogging:
		l("Adding translations as: %s" % csvLine)
	for i in range(1, csvLine.size()):
		var translationObject := Translation.new()
		translationObject.locale = csvLine[i]
		translations.append(translationObject)
	while not tlFile.eof_reached():
		csvLine = tlFile.get_csv_line(delim)
		if csvLine.size() > 1:
			var translationID := csvLine[0]
			for i in range(1, csvLine.size()):
				translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
			if fullLogging:
				l("Added translation: %s" % csvLine)
			translationCount += 1
	tlFile.close()
	for translationObject in translations:
		TranslationServer.add_translation(translationObject)
	l("%s Translations Updated from @ [%s]" % [translationCount, fileName])
func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = ResourceLoader.load(childPath)
	childScript.new()
	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path
	l("Installing script extension: %s <- %s" % [parentPath, childPath])
	childScript.take_over_path(parentPath)
func replaceScene(newPath:String, oldPath:String = ""):
	l("Updating scene: %s" % newPath)
	if oldPath.empty():
		oldPath = str("res://" + newPath)
	newPath = str(modPath + newPath)
	var scene := load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)
func loadDLC():
	l("Preloading DLC as workaround")
	var DLCLoader:Settings = preload("res://Settings.gd").new()
	DLCLoader.loadDLC()
	DLCLoader.queue_free()
	l("Finished loading DLC")
func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	Debug.l("[%s V%s]: %s" % [title, version, msg])
func loadSettings():
	installScriptExtension("Settings.gd")
	l(MOD_NAME + ": Loading mod settings")
	var settings = load("res://Settings.gd").new()
	settings.load_HevLib_FromFile()
	settings.save_HevLib_ToFile()
	modConfig = settings.HevLib
	l(MOD_NAME + ": Current settings: %s" % modConfig)
	settings.queue_free()
	l(MOD_NAME + ": Finished loading settings")


# Instances the equipment pointer for use with the proper functions
var Equipment = preload("res://HevLib/pointers/Equipment.gd")

# Adds new equipment slots from an input dictionary
# Requires the ADD_EQUIPMENT_SLOTS variable to be set up
# Check the documentation JSON for usage
func addEquipmentSlot(slot_data: Dictionary):
	var slot = Equipment.__make_slot(slot_data)
	ADD_EQUIPMENT_SLOTS.append(slot)
# Adds new equipment items from an input dictionary
# Requires the ADD_EQUIPMENT_ITEMS variable to be set up
# Check the documentation JSON for usage
func addEquipmentItem(item_data: Dictionary):
	var eqp = Equipment.__make_equipment(item_data)
	ADD_EQUIPMENT_ITEMS.append(eqp)

# Slot tags used for the default slots used as an example
var tags = {
	"MainWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_HIGH_STRESS","alignment":"ALIGNMENT_CENTER"},
	"MainLowWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_SPINAL","alignment":"ALIGNMENT_CENTER"},
	"LeftHighStress":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_HIGH_STRESS","alignment":"ALIGNMENT_LEFT"},
	"RightHighStress":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_HIGH_STRESS","alignment":"ALIGNMENT_RIGHT"},
	"LeftWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_LEFT"},
	"MiddleLeftWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_LEFT","override_subtractive":["EQUIPMENT_BEACON","EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_IMPACT_ABSORBER"]},
	"RightWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_RIGHT"},
	"MiddleRightWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_RIGHT","override_subtractive":["EQUIPMENT_BEACON","EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_IMPACT_ABSORBER"]},
	"LeftDroneSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DRONE_POINT","alignment":"ALIGNMENT_LEFT"},
	"RightDroneSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DRONE_POINT","alignment":"ALIGNMENT_RIGHT"},
	"LeftRearSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_LEFT","override_subtractive":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES","EQUIPMENT_SYNCHROTRONS","EQUIPMENT_BEACON"]},
	"RightRearSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_RIGHT","override_subtractive":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES","EQUIPMENT_SYNCHROTRONS","EQUIPMENT_BEACON"]},
	"LeftBay1":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_LEFT","override_additive":["EQUIPMENT_BEACON"]},
	"RightBay1":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_RIGHT","override_additive":["EQUIPMENT_BEACON"]},
	"LeftBay2":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_LEFT"},
	"RightBay2":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_RIGHT"},
	"LeftBay3":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_LEFT"},
	"RightBay3":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_RIGHT"},
	"AmmunitionDelivery":{"slot_type":"MASS_DRIVER_AMMUNITION"},
	"DisposableDrones":{"slot_type":"NANODRONE_STORAGE"},
	"Propellant":{"slot_type":"PROPELLANT_TANK"},
	"Thrusters":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"},
	"Torches":{"slot_type":"STANDARD_MAIN_ENGINE"},
	"Rods":{"slot_type":"FISSION_RODS"},
	"Capacitor":{"slot_type":"ULTRACAPACITOR"},
	"Turbine":{"slot_type":"FISSION_TURBINE"},
	"AuxilaryPower":{"slot_type":"AUX_POWER_SLOT"},
	"CargoBay":{"slot_type":"CARGO_BAY"},
	"Autopilot":{"slot_type":"AUTOPILOT"},
	"Hud":{"slot_type":"HUD"},
	"Lidar":{"slot_type":"LIDAR"},
	"ReconDrone":{"slot_type":"RECON_DRONE"},
}

var new_tags = {
	"TurretLeft":{"type":"HARDPOINT","hardpoint_type":"HARDPOINT_TURRET","hardpoint_alignment":"ALIGNMENT_LEFT","system_slot":"weaponSlot.turretLeft.type"},
	"TurretRight":{"type":"HARDPOINT","hardpoint_type":"HARDPOINT_TURRET","hardpoint_alignment":"ALIGNMENT_RIGHT","system_slot":"weaponSlot.turretRight.type"},
}

var new_equipment_tags = {
	"slot_types":[
		"SLOT_TURRETS"
	],
	"hardpoint_types":[
		"HARDPOINT_TURRET"
	],
	"hardpoint_defaults":{
		"HARDPOINT_TURRET":[
			"EQUIPMENT_TURRETS",
			"EQUIPMENT_NANODRONES"
		]
	}
}
