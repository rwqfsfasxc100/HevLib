extends Node

func make_child(dataDictionary, resolution, path, panel_name):
	
	
	var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")
	
	var get_panel = preload("res://HevLib/ui/core_scripts/get_panel.gd")
	
	var d = dataDictionary
#	var d = dataDictionary.get(data)
	var type = d.get("type")
	var texture = d.get("texture")
	var rightSpacePercent = d.get("rightSpacePercent")
	var leftSpacePercent = d.get("leftSpacePercent")
	var topSpacePercent = d.get("topSpacePercent")
	var bottomSpacePercent = d.get("bottomSpacePercent")
	var square = d.get("square")
	var square_align = d.get("square_align")
	var paneldta = d.get("data")
	var checkdata = handle_resolution.handle_resolution(resolution,rightSpacePercent,leftSpacePercent,topSpacePercent,bottomSpacePercent,square,square_align)
	var paneldata = get_panel.get_panel(type,texture)

	var panel = paneldata[0]
	panel.panelTexturePath = paneldata[1]
	panel.rect_size = checkdata[0]
	panel.rect_position = checkdata[1]
	panel.datastring = paneldta
	panel.name = panel_name
	
	
	panel.rightSpacePercent = d.get("rightSpacePercent")
	panel.leftSpacePercent = d.get("leftSpacePercent")
	panel.topSpacePercent = d.get("topSpacePercent")
	panel.bottomSpacePercent = d.get("bottomSpacePercent")
	
	return panel
#	add_child(panel)
#	if paneldta != null:
#		var panelPath = get_path_to(get_node(data))
#		var panelRes = checkdata[0]
#		get_node(data).makeChild(paneldta, panelRes, panelPath)
