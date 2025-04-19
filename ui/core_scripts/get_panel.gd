extends Node

static func get_panel(panel, texture):
	var panelPath = ""
	var texturePath = ""
	var index = preload("res://HevLib/ui/core_scripts/index.gd").new()
	panelPath = load(index.panel(panel))
	texturePath = index.texture(texture)
	return [panelPath.instance(), texturePath]
