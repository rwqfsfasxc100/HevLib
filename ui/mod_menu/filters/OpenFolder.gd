extends Button

export (String,"mods","exe","user","cache","cfg") var place_to_open = "mods"

var gameInstallDirectory = ""
var modPathPrefix = ""
var user_dir = "user://"
var cache_dir = "user://cache/"
var cfg_dir = "user://cfg/"

func _ready():
	gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	modPathPrefix = gameInstallDirectory.plus_file("mods")

func _pressed():
	match place_to_open:
		"mods":
			OS.shell_open(modPathPrefix)
		"exe":
			OS.shell_open(gameInstallDirectory)
		"user":
			OS.shell_open(user_dir)
		"cache":
			OS.shell_open(cache_dir)
		"cfg":
			OS.shell_open(cfg_dir)
