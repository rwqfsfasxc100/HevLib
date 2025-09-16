extends Label
onready var ps = SceneTree.new()
func _ready():
	ps.connect("files_dropped",self,"_files_dropped")
	

func _files_dropped(files,screen):
	breakpoint
