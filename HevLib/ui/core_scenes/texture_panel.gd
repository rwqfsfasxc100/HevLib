extends TextureRect

export var datastring = ""

export (float, 0, 200, 1) var leftSpacePercent = 20.0
export (float, 0, 200, 1) var rightSpacePercent = 20.0
export (float, 0, 200, 1) var topSpacePercent = 20.0
export (float, 0, 200, 1) var bottomSpacePercent = 20.0

export var set_size = Vector2(1280, 720)
export var set_pos = Vector2(0,0)

var handle_resolution = load("res://HevLib/ui/core_scripts/handle_resolution.gd").new()
var get_panel = load("res://HevLib/ui/core_scripts/get_panel.gd").new()

export (bool) var square = false

export (String) var panelTexturePath = ""

func _process(delta):
	handler()

func handler():
	
	var file = File.new()
	if file.open(panelTexturePath, File.READ) == OK:
		file.close()
		var tex = load(panelTexturePath)
		texture = tex
	else:
		file.close()
		var tex = load("res://HevLib/ui/panels/notexture.stex")
		texture = tex
		
	
#	var vpRect = get_parent().rect_size
#	var screenWidth = vpRect.x
#	var screenHeight = vpRect.y
#	var screenWidth = Settings.maxScreenScale.x - 2
#	var screenHeight = Settings.maxScreenScale.y - 2
#	if OS.get_name() == "Windows":
#		screenHeight -= 1
#
#	var offsetW = leftSpacePercent / 100.0
#	var offsetWidth = screenWidth * offsetW * 0.5
#	var offsetH = topSpacePercent / 100.0
#	var offsetHeight = screenHeight * offsetH * 0.5
#	var offsetW2 = rightSpacePercent / 100.0
#	var offsetWidth2 = screenWidth * offsetW2 * 0.5
#	var offsetH2 = bottomSpacePercent / 100.0
#	var offsetHeight2 = screenHeight * offsetH2 * 0.5
#	var sizeW = abs((200.0 - rightSpacePercent - leftSpacePercent) / 200.0)
#	var sizeWidth = screenWidth * sizeW
#	var sizeH = abs((200.0 - bottomSpacePercent - topSpacePercent) / 200.0)
#	var sizeHeight = screenHeight * sizeH
#
#
#	if square:
#		if sizeHeight > sizeWidth:
#			sizeHeight = sizeWidth
#		else:
#			sizeWidth = sizeHeight
#
#
#	rect_size.x = sizeWidth
#	rect_size.y = sizeHeight
#	rect_position.x = offsetWidth
#	rect_position.y = offsetHeight


#func _ready():
#
#	cHandle()
#
#func cHandle():
#	var handle_resolution = load("res://HevLib/ui/core_scripts/handle_resolution.gd").new()
#	var get_panel = load("res://HevLib/ui/core_scripts/get_panel.gd").new()
#	var resolution = get_parent().rect_size
#	var dataDictionary = datastring
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
	


func _on_texture_panel_visibility_changed():
#	handler()
#	cHandle()
	pass

func makeChild(dataDictionary, resolution, path):
	var make_child = load("res://HevLib/ui/core_scripts/make_child.gd").new()
	make_child.make_child(dataDictionary, resolution, path)
	
#
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
#		add_child(panel)
#		if paneldta != null:
#			var panelPath = get_path_to(get_node(data))
#			var panelRes = panel.rect_size
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
