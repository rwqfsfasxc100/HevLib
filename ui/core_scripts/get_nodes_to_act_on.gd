extends Node

var appendage = []

var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")

func get_nodes_to_act_on(dataDictionary, resolution):
	for data in dataDictionary:
		var path = data
		proc(dataDictionary.get(data), path, resolution)
	
	
	return appendage


func proc(dataDictionary, path, parent_resolution):
	var d = dataDictionary
	var type = d.get("type", "panel_margin")
	var texture = d.get("texture", "panel_tl_br")
	var rightSpacePercent = d.get("rightSpacePercent", 20)
	var leftSpacePercent = d.get("leftSpacePercent", 20)
	var topSpacePercent = d.get("topSpacePercent", 20)
	var bottomSpacePercent = d.get("bottomSpacePercent", 20)
	var square = d.get("square", false)
	var vertical_align = d.get("vertical_align", "top")
	var horizontal_align = d.get("horizontal_align", "left")
	var paneldta = d.get("data", {})
	var checkdata = handle_resolution.handle_resolution(parent_resolution,rightSpacePercent,leftSpacePercent,topSpacePercent,bottomSpacePercent,square,vertical_align, horizontal_align)
	
	
	var cArray = [path, checkdata[0], checkdata[1]]
	appendage.append(cArray)
	if not paneldta == {}:
		
		for data in paneldta:
			var path2 = path + "/" + data
			proc(paneldta.get(data), path2, checkdata[0])
