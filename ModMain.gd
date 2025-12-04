extends Node

const MOD_PRIORITY = INF
const MOD_NAME = "HevLib"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 10
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = true
const LIBRARY_HIDDEN_BY_DEFAULT = false
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []

var enable_research = false

var HevLibModMain = true
func _init(modLoader = ModLoader):
	l("Initializing DLC")
	loadDLC()
	installScriptExtension("events/TheRing.gd")
	installScriptExtension("scenes/notification_driver/CurrentGame.gd")
	replaceScene("scenes/notification_driver/Notifications.tscn","res://achievement/Notifications.tscn")
	
	
	
	var self_path = self.get_script().get_path()
	var self_directory = self_path.split(self_path.split("/")[self_path.split("/").size() - 1])[0]
	var self_check = load(self_directory + "self_check.tscn").instance()
	add_child(self_check)
	
	installScriptExtension("scenes/scene_replacements/Shipyard.gd")

var file = File.new()
var update_urls = PoolStringArray([])
var url_store = "user://cache/.Mod_Menu_2_Cache/updates/url_refs.json"
var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
var has_updated_store = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"

var dependancies_store = "user://cache/.Mod_Menu_2_Cache/dependancies/dependancies.json"
var conflicts_store = "user://cache/.Mod_Menu_2_Cache/conflicts/conflicts.json"
var complementary_store = "user://cache/.Mod_Menu_2_Cache/complementary/complementary.json"

var weaponslot_cache = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/ship_data"

var event_log_file = "user://cache/.HevLib_Cache/Event_Driver/event_log.json"
var active_events_file = "user://cache/.HevLib_Cache/Event_Driver/active_events.txt"
var latest_event_file = "user://cache/.HevLib_Cache/Event_Driver/latest_event.txt"

func _ready():
	l("Readying")
	var FolderAccess = load("res://HevLib/pointers/FolderAccess.gd")
	FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/updates/manifest_cache/")
	FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/updates/zip_cache/")
	FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/dependancies/")
	FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/conflicts/")
	FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/complementary/")
	FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/Event_Driver/")
	var zips = FolderAccess.__fetch_folder_files("user://cache/.Mod_Menu_2_Cache/updates/zip_cache/",true,true)
	var manifests = FolderAccess.__fetch_folder_files("user://cache/.Mod_Menu_2_Cache/updates/manifest_cache/",true,true)
	var d = Directory.new()
	for f in zips:
		d.remove(f)
	for f in manifests:
		d.remove(f)
	if d.dir_exists(weaponslot_cache):
		FolderAccess.__recursive_delete(weaponslot_cache)
	file.open(url_store,File.WRITE)
	file.store_string("[]")
	file.close()
	file.open(has_updated_store,File.WRITE)
	file.store_string("false")
	file.close()
	file.open(update_store,File.WRITE)
	file.store_string("{}")
	file.close()
	file.open(event_log_file,File.WRITE)
	file.store_string("{}")
	file.close()
	file.open(active_events_file,File.WRITE)
	file.store_string("")
	file.close()
	file.open(latest_event_file,File.WRITE)
	file.store_string("")
	file.close()
	var ManifestV2 = load("res://HevLib/pointers/ManifestV2.gd")
	var mod_data = ManifestV2.__get_mod_data(true,true)
	var md = ManifestV2.__get_mod_data()
	
	
	
	
	for item in md["mods"]:
		var data = md["mods"][item]["manifest"]
		if data["has_manifest"]:
			var url = data["manifest_data"]["manifest_definitions"]["manifest_url"]
			if url != "":
				var http = HTTPRequest.new()
				var pm = md["mods"][item]
				file.open(url_store,File.READ_WRITE)
				var current = JSON.parse(file.get_as_text()).result
				current.append([pm["name"],pm["manifest"]["manifest_data"]["mod_information"]["id"],pm["version_data"]["version_major"],pm["version_data"]["version_minor"],pm["version_data"]["version_bugfix"]])
				file.store_string(JSON.print(current))
				file.close()
				http.name = str(item.hash())
				http.connect("request_completed",self,"network_return")
				add_child(http)
				http.timeout = 20

				http.request(url)
				update_urls.append(pm["manifest"]["manifest_data"]["mod_information"]["id"])

	var conflicts = ManifestV2.__check_conflicts()
	var dependancies = ManifestV2.__check_dependancies()
	var complementary = ManifestV2.__check_complementary()
	
	file.open(conflicts_store,File.WRITE)
	file.store_string(JSON.print(conflicts))
	file.close()
	file.open(dependancies_store,File.WRITE)
	file.store_string(JSON.print(dependancies))
	file.close()
	file.open(complementary_store,File.WRITE)
	file.store_string(JSON.print(complementary))
	file.close()
	
	var ConfigDriver = load("res://HevLib/pointers/ConfigDriver.gd")
#	replaceScene("scenes/scene_replacements/MouseLayer.tscn", "res://menu/MouseLayer.tscn")
	if OS.has_feature("editor"):
		replaceScene("scenes/scene_replacements/TitleScreen.tscn", "res://TitleScreen.tscn")
#	var mouse = load("res://HevLib/scenes/scene_replacements/MouseLayer.tscn").instance()
	var CRoot = get_tree().get_root()
#	CRoot.call_deferred("add_child",mouse)
	
	replaceScene("scenes/scene_replacements/Game.tscn", "res://Game.tscn")
	var dir = Directory.new()
	dir.make_dir_recursive("user://cache/.HevLib_Cache/")
	var file = File.new()
	file.open("user://cache/.HevLib_Cache/library_documentation.json", File.WRITE)
	var HevLib = load("res://HevLib/pointers/HevLib.gd")
	var functionality = HevLib.__get_library_functionality(true)
	file.store_string(functionality)
	file.close()
	file.open("user://cache/.HevLib_Cache/currently_installed_mods.json", File.WRITE)
	file.store_string(str(mod_data))
	file.close()
	
	var cache_folder = "user://cache/.HevLib_Cache/Equipment_Driver/"
	replaceScene("scenes/crew_extensions/base_expansion_x24.tscn","res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn")
#	var CRoot = get_tree().get_root()
	if ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","use_legacy_equipment_handler"):
		var conv := []
		var paths = []
		FolderAccess.__check_folder_exists(cache_folder)
		var mods = ModLoader.get_children()
		l("Scanning installed mods for applicable mods")
		for mod in mods:
			var variants = mod.get_property_list()
			var dict = {}
			var does = false
			for it in variants:
				var iname = it.get("name")
				match iname:
					"ADD_EQUIPMENT_SLOTS":
						does = true
						var arr = mod.ADD_EQUIPMENT_SLOTS
						var arr2 = []
						for item in arr:
							arr2.append(item.duplicate(7))
						dict.merge({"ADD_EQUIPMENT_SLOTS":arr2})
					"ADD_EQUIPMENT_ITEMS":
						does = true
						var arr = mod.ADD_EQUIPMENT_ITEMS
						var arr2 = []
						for item in arr:
							arr2.append(item.duplicate(7))
						dict.merge({"ADD_EQUIPMENT_ITEMS":arr2})
					"EQUIPMENT_TAGS":
						does = true
						var item = mod.EQUIPMENT_TAGS
						dict.merge({"EQUIPMENT_TAGS":item.duplicate(true)})
						pass
					"SLOT_TAGS":
						does = true
						var item = mod.SLOT_TAGS
						dict.merge({"SLOT_TAGS":item.duplicate(true)})
						pass
			if does:
				var mPath = mod.get_script().get_path()
				var mHash = mPath.hash()
				conv.append([dict,mPath,mHash,mod.name])
				paths.append(mPath)
				l("Found mod at %s, labelling as %s" % [mPath, str(mHash)])
		var vNode = load("res://HevLib/scenes/equipment/var_nodes/EquipmentDriver.tscn").instance()
		vNode.conv = conv
		vNode.paths = paths
		vNode.name = "EquipmentDriver"
		CRoot.call_deferred("add_child",vNode)
	installScriptExtension("scenes/research/overhead_handle/Enceladus.gd")
	installScriptExtension("scenes/research/overhead_handle/AsteroidSpawner.gd")
	var nNode = load("res://HevLib/scenes/research/overhead_handle/ResearchOverheadHandle.tscn").instance()
	CRoot.call_deferred("add_child",nNode)
	var scene = load("res://HevLib/scenes/better_title_screen/TitleScreen.tscn")
	
#	replaceScene("scenes/equipment/Enceladus.tscn","res://enceladus/Enceladus.tscn")
	
	var ncrew = ManifestV2.__get_manifest_entry("tags","TAG_HANDLE_EXTRA_CREW")
	var count = 24
	for mod in ncrew:
		var data = ncrew[mod]
		if data > count:
			count = data
	var NodeAccess = load("res://HevLib/pointers/NodeAccess.gd")
	var crew = NodeAccess.__dynamic_crew_expander("user://cache/.HevLib_Cache/",count)
	if not crew == "":
		var escene := load(crew)
		escene.take_over_path("res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn")
	if enable_research:
		replaceScene("scenes/research/Enceladus.tscn","res://enceladus/Enceladus.tscn")
	
	
	var gameFiles = FolderAccess.__get_folder_structure("res://",false)
	file.open("user://cache/.HevLib_Cache/filesys.json",File.WRITE)
	if gameFiles.size() == 0:
		printerr("FAILED TO FETCH FILE SYSTEM")
		l("ERROR! FAILED TO FETCH FILE SYSTEM")
	var sys = JSON.print(gameFiles,"\t")
	file.store_string(sys)
	file.close()
	l("Ready")
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
func l(msg:String, title:String = MOD_NAME, version:String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	Debug.l("[%s V%s]: %s" % [title, version, msg])
func network_return(result, response_code,headers,body):
	if result == 0:
		var ManifestV2 = load("res://HevLib/pointers/ManifestV2.gd")
		var ConfigDriver = load("res://HevLib/pointers/ConfigDriver.gd")
		var p = body.get_string_from_utf8()
		var path = "user://cache/.Mod_Menu_2_Cache/updates/manifest_cache/network_manifest_%s.cfg"
		var path2 = "user://cache/.Mod_Menu_2_Cache/updates/network_manifest.json"
		var id = 0
		for i in body:
			id += i
		file.open(path % id,File.WRITE)
		file.store_string(p)
		file.close()
		file.open(url_store,File.READ)
		var current = JSON.parse(file.get_as_text(true)).result
		file.close()
#		var data = ConfigDriver.__config_parse(path)
#		file.open(path2,File.WRITE)
#		file.store_string(JSON.print(data))
#		file.close()
		var manifest = ManifestV2.__parse_file_as_manifest(path % id,true)
		var DataFormat = load("res://HevLib/pointers/DataFormat.gd")
		for item in current:
			if item[1] in update_urls:
				var nv1 = manifest["version"]["version_major"]
				var nv2 = manifest["version"]["version_minor"]
				var nv3 = manifest["version"]["version_bugfix"]
				var does = DataFormat.__compare_versions(item[2],item[3],item[4],nv1,nv2,nv3)
				if not does and item[1] == manifest["mod_information"]["id"]:
					file.open(update_store,File.READ_WRITE)
					var updates = JSON.parse(file.get_as_text()).result
					updates.merge({item[1]:{"name":item[0],"id":item[1],"version":[item[2],item[3],item[4]],"new_version":[nv1,nv2,nv3],"github":manifest["links"].get("HEVLIB_GITHUB",{"URL":""}).get("URL",""),"nexus":manifest["links"].get("HEVLIB_NEXUS",{"URL":""}).get("URL",""),"display":item[0] + " (" + item[1] + ")"}})
					file.store_string(JSON.print(updates))
					file.close()


