extends Node

func make_child(data, resolution, path, panelName):
	
	
	var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")
	
	var get_panel = preload("res://HevLib/ui/core_scripts/get_panel.gd")
	
#	var d = dataDictionary.get(data)
	var d = data
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
	
	var panelDataString = paneldta
	
	var panel = paneldata[0]
	panel.panelTexturePath = paneldata[1]
	panel.rect_size = checkdata[0]
	panel.rect_position = checkdata[1]
	panel.datastring = panelDataString
	panel.name = panelName
	

	panel.rightSpacePercent = data.get("rightSpacePercent")
	panel.leftSpacePercent = data.get("leftSpacePercent")
	panel.topSpacePercent = data.get("topSpacePercent")
	panel.bottomSpacePercent = data.get("bottomSpacePercent")

	
#		add_child(panel)
	return panel
#		if panelDataString != null:
#			var panelPath = get_path_to(get_node(data))
#			var panelRes = checkdata[0]
#			get_node(data).makeChild(panelDataString, panelRes, panelPath)
