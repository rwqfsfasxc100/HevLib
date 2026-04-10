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
	
	var cargo = geo.get_node(NodePath("MarginContainer/Cargo Panel"))
	var vb2 = cargo.get_node(NodePath("VBoxContainer2"))
	var rrect = vb2.rect_size
	var hb = HBoxContainer.new()
	cargo.remove_child(vb2)
	cargo.add_child(hb)
	cargo.move_child(hb,0)
	var vb = VBoxContainer.new()
	var l1 = vb2.get_node("Label List")
	var l2 = vb2.get_node("CargoManifest")
	vb2.remove_child(l1)
	vb2.remove_child(l2)
	vb.add_child(l1)
	vb.add_child(l2)
	hb.add_child(vb)
	hb.rect_size = rrect
	hb.size_flags_horizontal = SIZE_EXPAND_FILL
	var splitter = VBoxContainer.new()
	splitter.rect_min_size = Vector2(5,0)
	hb.add_child(splitter)
	hb.add_child(vb2)
	
	operated = true
func _process(delta):
	if operated:
		scroll.rect_size.y = mineral.rect_size.y + 20
