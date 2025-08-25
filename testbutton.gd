extends Button

var URL = "https://github.com/rwqfsfasxc100/HevLib"

var rng = RandomNumberGenerator.new()

var Globals = preload("res://HevLib/Functions.gd").new()

var hasGamespace = false
var hasActedOnGamespace = false
onready var panel = load("res://HevLib/ui/popup_main_base.tscn").instance()
var index = preload("res://HevLib/ui/core_scripts/index.gd").new()
var data = index.exampleDict
var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
func _physics_process(delta):
	var noMargins = get_node_or_null("/root/_HevLib_Gamespace_Canvas/MarginContainer")
	panel.datastring = data
	if not noMargins == null:
		hasGamespace = true 
	if hasGamespace == true and hasActedOnGamespace == false:
		hasActedOnGamespace = true
		connect("pressed",panel,"_pressed")
		noMargins.call_deferred("add_child",panel)
		var nnd = load("res://HevLib/ui/core_scripts/get_nodes_to_act_on.gd").new()
		var pnt = nnd.get_nodes_to_act_on(data, Vector2(1600,900))

func _on_Button_pressed():
	rng.randomize()
	var Translations = preload("res://HevLib/pointers/Translations.gd")
#	var mods = ManifestV2.__get_mod_data_from_files("user://cache/.HevLib_Cache/ManifestV2/derelictdelights/ModMain.gd", true)
#	var did = ManifestV2.__compare_versions(mods)
#	var webtranslate = preload("res://HevLib/pointers/WebTranslate.gd")
#	webtranslate.webtranslate(URL)
#	var pss = Globals.__get_current_achievements()
#	var psm = Globals.__get_achievement_data("DIVER_10")
#	var ap = Globals.__get_lib_variables()
#	var stat = Globals.__get_stat_data("stat:salvaged_ships")
#	Globals.__webtranslate_timed(URL, 5)
#	var text = TranslationServer.translate("DIALOG_SALVAGE_EXPOSE_FAST_K37_3")
#	
#	var gh = preload("res://HevLib/pointers/Github.gd").new()
#	gh.__get_github_filesystem(URL, self, "normal", "1.0.0")
#	
#	gh.__get_github_release("https://github.com/rwqfsfasxc100/HevLib", "user://temp", self, false, "any", "latest")
#	var hevlib_check = preload("res://HevLib/examples and documentation/hevlib_check.gd")
#	var hevlib_check_with_version = preload("res://HevLib/examples and documentation/hevlib_check_with_version.gd")
#	var does1 = hevlib_check.__hevlib_check()
#	var does2 = hevlib_check_with_version.__hevlib_check_with_version([1,7,1])
#	webtranslate.__webtranslate_reset_by_file_check("file_check")
	var tData = {
		"en":{
			"SHIP_OCP209_SPECS":"Yes",
			"STRING_B":"No",
		},
	}
#	Translations.__updateTL_drom_dictionary(tData)
	Translations.__inject_translations(tData)
	breakpoint
#	var node = Node.new()	
	
#	var wps = load("res://weapons/WeaponSlot.tscn").instance()
#	var nodes = []
#	for child in wps.get_children():
#		nodes.append(child.name)
	
	var mf = load("res://HevLib/scenes/equipment/make_upgrades_scene.gd").new()
	mf.make_upgrades_scene()
	breakpoint
	var mod_data = ManifestV2.__get_mod_data()
	
	var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
#
#	ConfigDriver.__store_config(config,"He/vL/ib/")
#
#	ConfigDriver.__store_value("HevLib","equipment","do_sort_equipment_by_price",false)
#	var does = ConfigDriver.__get_config("HevLib")
#	var el = ConfigDriver.__get_value("HevLib","equipment","do_sort_equipment_by_price")
	
	
	ConfigDriver.__load_configs()
	
#
#
#	var NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")
#	var crew = NodeAccess.__dynamic_crew_expander("user://cache/.HevLib_Cache/",25)
#	if not crew == "":
#		var scene := load(crew)
#		scene.take_over_path("res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn")
#
#	var crew2 = NodeAccess.__dynamic_crew_expander("user://cache/.HevLib_Cache/",30)
#	if not crew2 == "":
#		var scene2 := load(crew2)
#		scene2.take_over_path("res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn")
#
#	var test = load("res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn").instance()
#	var children = test.get_children()
#	var names = []
#	for child in children:
#		names.append(child.name)
	
	
	
	
	breakpoint

var updates = {}
var count = 1

func _on_update_completed(data):
	if data:
		updates.merge({count:data})
		count += 1

func _github_filesystem_data(data):
	pass

func _downloaded_zip(file, folder):
	pass



var config = {
	"equi/pme/nt":{
		"do_sort_equipment_by_price":true,
	},
	"e/vents":{
		"disabled_events":[  ],
		"write_events":true,
	},
	"de/bug":{
		"input_debugger":false,
		"ring_position_data_debugger":false,
		"ring_position_accurate_events":false,
	},
	"in/put":{
		"open_debug_event_menu":[  ],
		"debugger":[ "F10" ],
		"toggle_debug_menus":[ "F9" ],
	}, 
}
