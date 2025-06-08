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
	var mods = ManifestV2.__get_mod_data_from_files("user://cache/.HevLib_Cache/ManifestV2/derelictdelights/ModMain.gd", true)
	var did = ManifestV2.__compare_versions(mods)
	breakpoint#	var webtranslate = preload("res://HevLib/webtranslate/webtranslate.gd").new()
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
	
#	gh.__get_github_release("https://github.com/rwqfsfasxc100/HevLib", "user://temp", self, false, "any", "latest")
	
	
	pass

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
