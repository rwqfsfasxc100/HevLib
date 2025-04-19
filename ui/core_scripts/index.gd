extends Node

# Popup handle
export var popup_main_base = "res://HevLib/ui/core_scenes/popup_main_base.tscn"

# Panel window. Do note that size is relative to the screen's resolution.
# Is best used for containers that span the entire screen. Use section_margin instead if you want to use it within a smaller container
export var panel_margin = "res://HevLib/ui/core_scenes/panel_margin.tscn"

# Panel window to be used within another container
export var section_margin = "res://HevLib/ui/core_scenes/section_margin.tscn"

# Image window that will scale to the bounds provided
export var texture_panel = "res://HevLib/ui/core_scenes/texture_panel.tscn"



# Panel ninepatchrect textures
export var panel_corners_all = "res://HevLib/ui/panels/all.stex"

export var panel_bl_br = "res://HevLib/ui/panels/bl_br.stex"

export var panel_corners_none = "res://HevLib/ui/panels/none.stex"

export var panel_tl_bl = "res://HevLib/ui/panels/tl_bl.stex"

export var panel_tl_br = "res://HevLib/ui/panels/tl_br.stex"

export var panel_tl_tr = "res://HevLib/ui/panels/tl_tr.stex"

export var panel_tr_bl = "res://HevLib/ui/panels/tr_bl.stex"

export var panel_tr_br = "res://HevLib/ui/panels/tr_br.stex"

export var notexture = "res://HevLib/ui/panels/notexture.stex"



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
					"type":"section_margin",
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
