extends Node

var appendage = []

var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")

func get_nodes_to_act_on(dataDictionary, resolution):
	for data in dataDictionary:
		var path = data
		proc(dataDictionary.get(data), path, resolution)
	
	
	return appendage


func proc(dataDictionary, path, parent_resolution):
	
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
	var checkdata = handle_resolution.handle_resolution(parent_resolution,rightSpacePercent,leftSpacePercent,topSpacePercent,bottomSpacePercent,square,vertical_align, horizontal_align)
	
	
	var cArray = [path, checkdata[0], checkdata[1]]
	appendage.append(cArray)
	var dataDict = d.get("data")
	if not dataDict == {}:
		
		for data in dataDict:
			var path2 = path + "/" + data
			proc(dataDict.get(data), path2, checkdata[0])
