extends "res://hud/OMS.gd"

var geo
var mineral
var scroll

var operated = false

func _ready():
	geo = $MarginContainer/VBoxContainer/TabHintContainer/TabContainer/CREW_OCCUPATION_GEOLOGIST
	scroll = ScrollContainer.new()
	scroll.set_script(load("res://HevLib/scripts/ScrollWithAnalogHorizontal.gd"))
#	scroll.follow_focus = true
	scroll.rect_size = geo.rect_size
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	geo.add_child(scroll)
	mineral = geo.get_node("SystemMineralList")
	geo.remove_child(mineral)
	mineral.size_flags_vertical = SIZE_FILL
	scroll.add_child(mineral)
	operated = true
func _process(delta):
	if operated:
		scroll.rect_size.y = mineral.rect_size.y + 20
