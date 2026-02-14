extends Label

var modPathPrefix = ""
var pointers
func _ready():
	get_tree().connect("files_dropped",self,"_files_dropped")
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	modPathPrefix = gameInstallDirectory.plus_file("mods")
	

#var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
func _files_dropped(files,screen):
	if is_visible_in_tree():
		if not pointers:
			pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
		if pointers:
			pointers.FolderAccess.__check_folder_exists(modPathPrefix)
			for file in files:
				pointers.FolderAccess.__copy_file(file,modPathPrefix)
