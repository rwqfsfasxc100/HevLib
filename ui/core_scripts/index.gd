extends Node

var scene_folder = "res://HevLib/ui/core_scenes/"

var texture_folder = "res://HevLib/ui/panels/"

func panel(pan):
	var panelType = "panel_margin.tscn"
	match pan:
		"popup_main_base":
			panelType = "popup_main_base.tscn"
		"panel_margin":
			panelType = "panel_margin.tscn"
		"texture_panel": 
			panelType = "texture_panel.tscn"
		"label_margin":
			panelType = "label_margin.tscn"
		_: 
			panelType = "panel_margin.tscn"
	return scene_folder + panelType
# Panel ninepatchrect textures
func texture(tex):
	var textureType = "tl_br.stex"
	match tex:
		"panel_corners_all":
			textureType = "all.stex"
		"panel_bl_br": 
			textureType = "bl_br.stex"
		"panel_corners_none": 
			textureType = "none.stex"
		"panel_tl_bl": 
			textureType = "tl_bl.stex"
		"panel_tl_br": 
			textureType = "tl_br.stex"
		"panel_tl_tr": 
			textureType = "tl_tr.stex"
		"panel_tr_bl": 
			textureType = "tr_bl.stex"
		"panel_tr_br": 
			textureType = "tr_br.stex"
		"notexture": 
			textureType = "notexture.stex"
		"none": 
			textureType = "notexture.stex"
		_:
			textureType = tex
	return texture_folder + textureType

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
			"topSpacePercent":5,
			"theme":"res://HevLib/ui/themes/hev_theme.tres",
			"data":{
				"panel1":{
					"type":"label_margin",
					"text":"uiweysuhkdsygjhfusydgcxvgh",
					"autowrap":true,
					"uppercase":true,
					"bottomSpacePercent":180,
				},
			},
		}
	}
