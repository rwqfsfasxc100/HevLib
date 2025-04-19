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
export (String, "top", "bottom", "center") var vertical_align = "top"
export (String, "left", "right", "center") var horizontal_align = "left"

export (String) var panelTexturePath = ""

func _ready():
	handler()
	var make_child = load("res://HevLib/ui/core_scripts/make_child.gd").new()
	var path = get_path_to(self)
	for data in datastring:
		var panel_name = data
		var panel = make_child.make_child(datastring.get(data), set_size, path, panel_name)
		add_child(panel)

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
		
	
	

func _process(delta):
	handler()
	var checkdata = handle_resolution.handle_resolution(get_parent().rect_size,rightSpacePercent,leftSpacePercent,topSpacePercent,bottomSpacePercent,square,vertical_align, horizontal_align)
	rect_size = checkdata[0]
	rect_position = checkdata[1]
