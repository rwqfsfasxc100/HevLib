extends Label

var modPathPrefix = ""

func _ready():
	get_tree().connect("files_dropped",self,"_files_dropped")
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	modPathPrefix = gameInstallDirectory.plus_file("mods")
	FolderAccess.__check_folder_exists(modPathPrefix)
	
var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
func _files_dropped(files,screen):
	if is_visible_in_tree():
		for file in files:
			FolderAccess.__copy_file(file,modPathPrefix)
	
	
	
