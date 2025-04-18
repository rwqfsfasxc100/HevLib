extends Node

static func make_panels(jdata, resolution):
	var get_panel = preload("res://HevLib/ui/core_scripts/get_panel.gd")
	var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")
	var dataDictionary = JSON.parse(jdata).result
	for each in dataDictionary:
		var data = dataDictionary.get(each)
		var checkdata = handle_resolution.handle_resolution(resolution,data.get("rightSpacePercent"),data.get("leftSpacePercent"),data.get("topSpacePercent"),data.get("bottomSpacePercent"),data.get("square"),data.get("square_align"))
		var paneldata = get_panel.get_panel(data.get("type"),data.get("texture"))
		
		var panel = paneldata[0]
		panel.panelTexturePath = paneldata[1]
		panel.rect_size = checkdata[0]
		panel.rect_position = checkdata[1]
		panel.datastring = data.get("data")
		
	
