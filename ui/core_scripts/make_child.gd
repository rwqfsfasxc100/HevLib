extends Node

func make_child(dataDictionary, resolution, path, panel_name):
	
	var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")
	
	var get_panel = preload("res://HevLib/ui/core_scripts/get_panel.gd")
	var d = dataDictionary
	var script = d.get("script","")
	var theme = d.get("theme","")
	var type = d.get("type", "panel_margin")
	var texture = d.get("texture", "panel_tl_br")
	var rightSpacePercent = d.get("rightSpacePercent", 20)
	var leftSpacePercent = d.get("leftSpacePercent", 20)
	var topSpacePercent = d.get("topSpacePercent", 20)
	var bottomSpacePercent = d.get("bottomSpacePercent", 20)
	var square = d.get("square", false)
	var square_vertical_align = d.get("square_vertical_align", "top")
	var square_horizontal_align = d.get("square_horizontal_align", "left")
	var paneldta = d.get("data", {})
	var checkdata = handle_resolution.handle_resolution(resolution,rightSpacePercent,leftSpacePercent,topSpacePercent,bottomSpacePercent,square,square_vertical_align, square_horizontal_align)
	var paneldata = get_panel.get_panel(type,texture)
	var panel = paneldata[0]
	# LabelMargin specific data
	
	panel.panelTexturePath = paneldata[1]
#	panel.rect_min_size = checkdata[0]
	panel.rect_size = checkdata[0]
	
	panel.set_size = checkdata[0]
	panel.set_pos = checkdata[1]
	
	panel.rect_position = checkdata[1]
	panel.datastring = paneldta
	panel.name = panel_name
	
	
	panel.scriptPath = script
	if type == "label_margin":
		panel.panelText = d.get("text", "")
		panel.borderBuffer = d.get("borderBuffer", true)
		panel.textboxOffset = d.get("textboxOffset", Vector2(0,0))
		panel.autowrap = d.get("autowrap", true)
		panel.text_horizontal_align = d.get("text_horizontal_align", 0)
		panel.text_vertical_align = d.get("text_vertical_align", 0)
		panel.clip_text = d.get("clip_text", false)
		panel.uppercase = d.get("uppercase", false)
		panel.visible_characters = d.get("visible_characters", -1)
		panel.percent_visible = d.get("percent_visible", 1.0)
		panel.lines_skipped = d.get("lines_skipped", 0)
		panel.max_lines_visible = d.get("max_lines_visible", -1)
		
		# LabelMargin default overrides
		rightSpacePercent = d.get("rightSpacePercent", 0)
		leftSpacePercent = d.get("leftSpacePercent", 0)
		topSpacePercent = d.get("topSpacePercent", 0)
		bottomSpacePercent = d.get("bottomSpacePercent", 0)
		texture = d.get("texture", "notexture")
		var index = preload("res://HevLib/ui/core_scripts/index.gd").new()
		panel.panelTexturePath = index.texture(texture)
		pass
	var dir = Directory.new()
	var hasTheme = dir.file_exists(theme)
	if hasTheme:
		theme = load(theme)
		panel.theme = theme
	elif theme == "":
		Debug.l("Theme for %s is blank, defaulting" % self.name)
	else:
		Debug.l("Invalid theme set for %s, skipping" % self.name)
	
	panel.rightSpacePercent = rightSpacePercent
	panel.leftSpacePercent = leftSpacePercent
	panel.topSpacePercent = topSpacePercent
	panel.bottomSpacePercent = bottomSpacePercent
	return panel
