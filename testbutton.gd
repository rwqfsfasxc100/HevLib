extends Button

var URL = "https://github.com/rwqfsfasxc100/HevLib"

var Globals = preload("res://HevLib/Functions.gd").new()
var HevLib = preload("res://HevLib/pointers/HevLib.gd").new()

#func _ready():
#	var noMargins = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("NoMargins")
#	var data = {
#		"panel1":{
#			"type":"panel_margin",
#			"texture":"panel_tl_tr",
#			"topSpacePercent":20,
#			"leftSpacePercent":20,
#			"bottomSpacePercent":120,
#			"rightSpacePercent":120,
#			"square":false,
#			"square_align":"left",
#			"data":{
#				"panel1":{
#					"type":"section_margin",
#					"texture":"panel_tl_tr",
#					"topSpacePercent":60,
#					"leftSpacePercent":60,
#					"bottomSpacePercent":60,
#					"rightSpacePercent":60,
#					"square":true,
#					"square_align":"right",
#					"data":{}
#				},
#			}
#		},
#		"panel2":{
#			"type":"panel_margin",
#			"texture":"panel_tl_tr",
#			"topSpacePercent":110,
#			"leftSpacePercent":50,
#			"bottomSpacePercent":70,
#			"rightSpacePercent":30,
#			"square":false,
#			"square_align":"left",
#			"data":{}
#		}
#	}
#	var panel = preload("res://HevLib/ui/popup_main_base.tscn").instance()
#	panel.datastring = data
	
	
	
#	connect("pressed",panel,"_pressed")
#	noMargins.add_child(panel)
	

func _on_Button_pressed():
#	var webtranslate = preload("res://HevLib/webtranslate/webtranslate.gd").new()
#	webtranslate.webtranslate(URL)
#	var pss = Globals.__get_current_achievements()
#	var psm = Globals.__get_achievement_data("DIVER_10")
#	var ap = Globals.__get_lib_variables()
	var stat = Globals.__get_stat_data("stat:salvaged_ships")
#	Globals.__webtranslate_timed(URL, 5)
	var text = TranslationServer.translate("DIALOG_SALVAGE_EXPOSE_FAST_K37_3")
#
#	var pointers = HevLib.__get_lib_pointers()
#	var pointers2 = HevLib.__get_pointer_functions("Zip.gd")
#	var pointers3 = HevLib.__get_library_functionality()
	
	
	var gh = preload("res://HevLib/pointers/Github.gd").new()
#	gh.__get_github_filesystem(URL, self, "normal", "1.0.0")
	
	gh.__get_github_release("https://github.com/rwqfsfasxc100/HevLib", "user://temp", self, false, "any", "latest")
	
	
	

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
