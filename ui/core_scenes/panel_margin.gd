extends Panel

export var datastring = ""

var handle_resolution = load("res://HevLib/ui/core_scripts/handle_resolution.gd").new()
var get_panel = load("res://HevLib/ui/core_scripts/get_panel.gd").new()

export (float, 0, 200, 1) var leftSpacePercent = 20.0
export (float, 0, 200, 1) var rightSpacePercent = 20.0
export (float, 0, 200, 1) var topSpacePercent = 20.0
export (float, 0, 200, 1) var bottomSpacePercent = 20.0

export var set_size = Vector2(1280, 720)
export var set_pos = Vector2(0,0)

export (bool) var square = false
export (String, "top", "bottom", "center") var square_vertical_align = "top"
export (String, "left", "right", "center") var square_horizontal_align = "left"

export (String) var panelTexturePath = ""

export (String) var scriptPath = ""

func _ready():
	handler()
	initialization()

func initialization():
	var make_child = load("res://HevLib/ui/core_scripts/make_child.gd").new()
	var path = get_path_to(self)
	for data in datastring:
		var panel_name = data
		var panel = make_child.make_child(datastring.get(data), set_size, path, panel_name)
		add_child(panel)
	var dir = Directory.new()
	if dir.file_exists(scriptPath):
		$script_node.set_script(load(scriptPath))
	elif scriptPath == "":
		Debug.l("No script for %s, skipping" % self.name)
	else:
		Debug.l("UI script failed to load at %s / %s" % [self.name, $script_node.name])

func handler():
	var file = File.new()
	if file.open(panelTexturePath, File.READ) == OK:
		file.close()
		var tex = load(panelTexturePath)
		$NinePatchRect.texture = tex
	else:
		file.close()
		var tex = load("res://HevLib/ui/panels/tl_br.stex")
		$NinePatchRect.texture = tex

func _process(delta):
	handler()
	var parent_size = get_parent().rect_size
	var checkdata = handle_resolution.handle_resolution(parent_size,rightSpacePercent,leftSpacePercent,topSpacePercent,bottomSpacePercent,square,square_vertical_align, square_horizontal_align)
	rect_size = checkdata[0]
	rect_position = checkdata[1]
	set_size = checkdata[0]
	set_pos = checkdata[1]
	$NinePatchRect.rect_size = checkdata[0]
