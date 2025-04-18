extends Node

func make_child(dataDictionary, resolution, path, panel_name):
	
	var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")
	
	var get_panel = preload("res://HevLib/ui/core_scripts/get_panel.gd")
	
	var d = {
		"type":"panel_margin",
		"texture":"panel_tl_br",
		"topSpacePercent":20,
		"leftSpacePercent":20,
		"bottomSpacePercent":20,
		"rightSpacePercent":20,
		"square":false,
		"vertical_align":"top",
		"horizontal_align":"left",
		"data":{}
	}
	for mir in dataDictionary:
		match mir:
			"type":
				var dict = {"type":dataDictionary.get(mir)}
				d.merge(dict, true)
			"texture":
				var dict = {"texture":dataDictionary.get(mir)}
				d.merge(dict, true)
			"rightSpacePercent":
				var dict = {"rightSpacePercent":dataDictionary.get(mir)}
				d.merge(dict, true)
			"leftSpacePercent":
				var dict = {"leftSpacePercent":dataDictionary.get(mir)}
				d.merge(dict, true)
			"topSpacePercent":
				var dict = {"topSpacePercent":dataDictionary.get(mir)}
				d.merge(dict, true)
			"bottomSpacePercent":
				var dict = {"bottomSpacePercent":dataDictionary.get(mir)}
				d.merge(dict, true)
			"square":
				var dict = {"square":dataDictionary.get(mir)}
				d.merge(dict, true)
			"vertical_align":
				var dict = {"vertical_align":dataDictionary.get(mir)}
				d.merge(dict, true)
			"horizontal_align":
				var dict = {"horizontal_align":dataDictionary.get(mir)}
				d.merge(dict, true)
			"data":
				var dict = {"data":dataDictionary.get(mir)}
				d.merge(dict, true)
#	var d = dataDictionary.get(data)
	var type = d.get("type")
	var texture = d.get("texture")
	var rightSpacePercent = d.get("rightSpacePercent")
	var leftSpacePercent = d.get("leftSpacePercent")
	var topSpacePercent = d.get("topSpacePercent")
	var bottomSpacePercent = d.get("bottomSpacePercent")
	var square = d.get("square")
	var vertical_align = d.get("vertical_align")
	var horizontal_align = d.get("horizontal_align")
	var paneldta = d.get("data")
	var checkdata = handle_resolution.handle_resolution(resolution,rightSpacePercent,leftSpacePercent,topSpacePercent,bottomSpacePercent,square,vertical_align, horizontal_align)
	var paneldata = get_panel.get_panel(type,texture)

	var panel = paneldata[0]
	panel.panelTexturePath = paneldata[1]
	panel.rect_min_size = checkdata[0]
	panel.rect_size = checkdata[0]
	
	panel.set_size = checkdata[0]
	panel.set_pos = checkdata[1]
	
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
