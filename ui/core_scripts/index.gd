extends Node


func panel(pan):
	match pan:
		"popup_main_base":
			return "res://HevLib/ui/core_scenes/popup_main_base.tscn"
		"panel_margin":
			return "res://HevLib/ui/core_scenes/panel_margin.tscn"
		"texture_panel": 
			return "res://HevLib/ui/core_scenes/texture_panel.tscn"
		_: 
			return "res://HevLib/ui/core_scenes/panel_margin.tscn"

# Panel ninepatchrect textures
func texture(tex):
	match tex:
		"panel_corners_all":
			return "res://HevLib/ui/panels/all.stex"
		"panel_bl_br": 
			return "res://HevLib/ui/panels/bl_br.stex"
		"panel_corners_none": 
			return "res://HevLib/ui/panels/none.stex"
		"panel_tl_bl": 
			return "res://HevLib/ui/panels/tl_bl.stex"
		"panel_tl_br": 
			return "res://HevLib/ui/panels/tl_br.stex"
		"panel_tl_tr": 
			return "res://HevLib/ui/panels/tl_tr.stex"
		"panel_tr_bl": 
			return "res://HevLib/ui/panels/tr_bl.stex"
		"panel_tr_br": 
			return "res://HevLib/ui/panels/tr_br.stex"
		"notexture": 
			return "res://HevLib/ui/panels/notexture.stex"
		_:
			return tex

# Example dictionary used for UI generation
# Dictionary used to create a heirarchical structure
  # Entries on the same level will be drawn at the same level, with earlier entries being drawn over by later entries
  # Data dictionary within each entry handles heirarchy within the panel
# Entry name is used purely for identification and doesn't matter what each is named
var exampleDict = {
		"panel1":{
			"leftSpacePercent":175,
			"rightSpacePercent":10,
			"topSpacePercent":50,
			"bottomSpacePercent":50,
			"texture":"panel_tr_br"
		},
		"panel":{},
		"panel2":{
			"rightSpacePercent":160,
			"topSpacePercent":5
		}
	}
