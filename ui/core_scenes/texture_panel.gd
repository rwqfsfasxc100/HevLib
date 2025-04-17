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
		
	
func _ready():
	var path = get_path_to(self)
	var make_child = load("res://HevLib/ui/core_scripts/make_child.gd").new()
	for data in datastring:
		var panel = make_child.make_child(datastring.get(data), rect_size, path, data)
		add_child(panel)
