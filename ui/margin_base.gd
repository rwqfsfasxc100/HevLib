extends MarginContainer

var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")

var get_panel = preload("res://HevLib/ui/core_scripts/get_panel.gd")


func _process(delta):
	var vpRect = get_viewport_rect().size
	var screenWidth = vpRect.x
	var screenHeight = vpRect.y
	var panelWidth = Settings.maxScreenScale.x - 2
	var panelHeight = Settings.maxScreenScale.y - 2
	if OS.get_name() == "Windows":
		screenHeight -= 1
	margin_right = screenWidth
	margin_bottom = screenHeight
	margin_left = 0
	margin_top = 0

func _ready():
	parseData()
	
	
	
	pass

func parseData():
	var resolution = get_viewport_rect().size
	var dataDictionary = get_parent().datastring
	var path = get_path_to(self)
	var make_child = load("res://HevLib/ui/core_scripts/make_child.gd").new()
	make_child.make_child(dataDictionary, resolution, path)











#func makeChild(dataDictionary, resolution, path):
#	for data in dataDictionary:
#		var d = dataDictionary.get(data)
#		var type = d.get("type")
#		var texture = d.get("texture")
#		var rightSpacePercent = d.get("rightSpacePercent")
#		var leftSpacePercent = d.get("leftSpacePercent")
#		var topSpacePercent = d.get("topSpacePercent")
#		var bottomSpacePercent = d.get("bottomSpacePercent")
#		var square = d.get("square")
#		var square_align = d.get("square_align")
#		var paneldta = d.get("data")
#		var checkdata = handle_resolution.handle_resolution(resolution,rightSpacePercent,leftSpacePercent,topSpacePercent,bottomSpacePercent,square,square_align)
#		var paneldata = get_panel.get_panel(type,texture)
#
#		var panel = paneldata[0]
#		panel.panelTexturePath = paneldata[1]
#		panel.rect_size = checkdata[0]
#		panel.rect_position = checkdata[1]
#		panel.datastring = paneldta
#		panel.name = data
#
#
#		panel.rightSpacePercent = data.get("rightSpacePercent")
#		panel.leftSpacePercent = data.get("leftSpacePercent")
#		panel.topSpacePercent = data.get("topSpacePercent")
#		panel.bottomSpacePercent = data.get("bottomSpacePercent")
#
#
#		add_child(panel)
#		if paneldta != null:
#			var panelPath = get_path_to(get_node(data))
#			var panelRes = checkdata[0]
#			get_node(data).makeChild(paneldta, panelRes, panelPath)
#
#
#			pass
#
#
#		pass
#
#
#	pass




func childManager(nodePath, data):
	
	
	
	pass

#func _ready():
#
#	cHandle()
#
#func cHandle():
#	var resolution = get_viewport_rect().size
#	var dataDictionary = get_parent().datastring
#	for each in dataDictionary:
#		var data = dataDictionary.get(each)
#		var checkdata = handle_resolution.handle_resolution(resolution,data.get("rightSpacePercent"),data.get("leftSpacePercent"),data.get("topSpacePercent"),data.get("bottomSpacePercent"),data.get("square"),data.get("square_align"))
#		var paneldata = get_panel.get_panel(data.get("type"),data.get("texture"))
#
#		var panel = paneldata[0]
#		panel.panelTexturePath = paneldata[1]
#		panel.rect_size = checkdata[0]
#		panel.rect_position = checkdata[1]
#		panel.datastring = data.get("data")
#		panel.name = each
#
#		panel.rightSpacePercent = data.get("rightSpacePercent")
#		panel.leftSpacePercent = data.get("leftSpacePercent")
#		panel.topSpacePercent = data.get("topSpacePercent")
#		panel.bottomSpacePercent = data.get("bottomSpacePercent")
#
#
#		add_child(panel)
#		pass
