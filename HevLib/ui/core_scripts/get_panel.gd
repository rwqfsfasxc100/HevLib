extends Node

static func get_panel(panel, texture):
	var panelPath = ""
	var texturePath = ""
	match panel:
#		"popup_main_base":
#			panelPath = preload("res://HevLib/ui/popup_main_base.tscn")
		"panel_margin":
			panelPath = preload("res://HevLib/ui/core_scenes/panel_margin.tscn")
		"section_margin":
			panelPath = preload("res://HevLib/ui/core_scenes/section_margin.tscn")
		"texture_panel":
			panelPath = preload("res://HevLib/ui/core_scenes/texture_panel.tscn")
		_:
			panelPath = preload("res://HevLib/ui/core_scenes/section_margin.tscn")
	match texture:
		"panel_corners_all":
			texturePath = "res://HevLib/ui/panels/all.stex"
		"panel_bl_br":
			texturePath = "res://HevLib/ui/panels/bl_br.stex"
		"panel_corners_none":
			texturePath = "res://HevLib/ui/panels/none.stex"
		"panel_tl_bl":
			texturePath = "res://HevLib/ui/panels/tl_bl.stex"
		"panel_tl_br":
			texturePath = "res://HevLib/ui/panels/tl_br.stex"
		"panel_tl_tr":
			texturePath = "res://HevLib/ui/panels/tl_tr.stex"
		"panel_tr_bl":
			texturePath = "res://HevLib/ui/panels/tr_bl.stex"
		"panel_tr_br":
			texturePath = "res://HevLib/ui/panels/tr_br.stex"
		"notexture":
			texturePath = "res://HevLib/ui/panels/notexture.stex"
		_:
			texturePath = "res://HevLib/ui/panels/tl_br.stex"
		
	return [panelPath.instance(), texturePath]
