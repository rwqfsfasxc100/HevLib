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
			return "res://HevLib/ui/panels/tl_br.stex"

# Example dictionary used for UI generation
# Dictionary used to create a heirarchical structure
  # Entries on the same level will be drawn at the same level, with earlier entries being drawn over by later entries
  # Data dictionary within each entry handles heirarchy within the panel
# Entry name is used purely for identification and doesn't matter what each is named
var exampleDict = {
		"panel1":{
			"texture":"panel_tl_tr",
			"bottomSpacePercent":120,
			"rightSpacePercent":120,
			"data":{
				"panel1":{
					"type":"panel_margin",
					"texture":"panel_tl_tr",
					"topSpacePercent":60,
					"leftSpacePercent":60,
					"bottomSpacePercent":60,
					"rightSpacePercent":60,
					"square":true,
					"horizontal_align":"right",
					"vertical_align":"top",
					"data":{
						"panel1":{
							"type":"texture_panel",
							"texture":"res://ModMenu/icon.png.stex",
							"topSpacePercent":40,
							"leftSpacePercent":40,
							"bottomSpacePercent":40,
							"rightSpacePercent":40,
							"square":true,
							"horizontal_align":"center",
							"vertical_align":"top"
						}
					}
				},
			}
		},
		"panel2":{
			"texture":"panel_tl_tr",
			"topSpacePercent":110,
			"leftSpacePercent":50,
			"bottomSpacePercent":70,
			"rightSpacePercent":30
		},
		"panel3":{
			"type":"texture_panel",
			"texture":"res://ModMenu/icon.png.stex",
			"topSpacePercent":90,
			"leftSpacePercent":70,
			"bottomSpacePercent":70,
			"rightSpacePercent":90,
			"square":true
			
		}
	}
