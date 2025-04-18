extends Node

var appendage = []

var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")

func get_nodes_to_act_on(dataDictionary, resolution):
	for data in dataDictionary:
		proc(dataDictionary.get(data), data, resolution)
	
	
	return appendage


func proc(dataDictionary, path, parent_resolution):
	
	var d = dataDictionary
	var rightSpacePercent = d.get("rightSpacePercent")
	var leftSpacePercent = d.get("leftSpacePercent")
	var topSpacePercent = d.get("topSpacePercent")
	var bottomSpacePercent = d.get("bottomSpacePercent")
	var square = d.get("square")
	var square_align = d.get("square_align")
	var paneldta = d.get("data")
	var checkdata = handle_resolution.handle_resolution(parent_resolution,rightSpacePercent,leftSpacePercent,topSpacePercent,bottomSpacePercent,square,square_align)
	
	
	
	var cArray = [path, checkdata[0], checkdata[1]]
	appendage.append(cArray)
	var dataDict = d.get("data")
	if not dataDict == {}:
		
		for data in dataDict:
			proc(dataDict.get(data), data, checkdata[0])
