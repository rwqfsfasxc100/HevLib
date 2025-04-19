extends Button

var URL = "https://github.com/rwqfsfasxc100/HevLib"

var Globals = preload("res://HevLib/Functions.gd").new()
var HevLib = preload("res://HevLib/pointers/HevLib.gd").new()

func _ready():
	var noMargins = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("NoMargins")
	var index = preload("res://HevLib/ui/core_scripts/index.gd").new()
	var data = index.exampleDict
	var panel = load("res://HevLib/ui/popup_main_base.tscn").instance()
	panel.datastring = data
	
	
	
	connect("pressed",panel,"_pressed")
	noMargins.add_child(panel)
	var nnd = load("res://HevLib/ui/core_scripts/get_nodes_to_act_on.gd").new()
	var pnt = nnd.get_nodes_to_act_on(data, Vector2(1600,900))
	pass

func _on_Button_pressed():
#	var webtranslate = preload("res://HevLib/webtranslate/webtranslate.gd").new()
#	webtranslate.webtranslate(URL)
#	var pss = Globals.__get_current_achievements()
#	var psm = Globals.__get_achievement_data("DIVER_10")
#	var ap = Globals.__get_lib_variables()
#	var stat = Globals.__get_stat_data("stat:salvaged_ships")
#	Globals.__webtranslate_timed(URL, 5)
#	var text = TranslationServer.translate("DIALOG_SALVAGE_EXPOSE_FAST_K37_3")
#
#	var pointers = HevLib.__get_lib_pointers()
#	var pointers2 = HevLib.__get_pointer_functions("Zip.gd")
#	var pointers3 = HevLib.__get_library_functionality()
	
	
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
