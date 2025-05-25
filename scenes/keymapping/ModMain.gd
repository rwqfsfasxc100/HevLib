extends Node

const MOD_PRIORITY = INF
const MOD_NAME = "HevLib Library Keymapping & Variable Node Module"
const MOD_VERSION = "1.0.0"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 0
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = true
func _init(modLoader = ModLoader):
	l("Initializing Keymapping & Variable nodes")
func _ready():
	l("Readying")
	var CRoot = get_tree().get_root()
	
	var NodeNew = Node.new()
	NodeNew.set_script(load("res://HevLib/scripts/Variables.gd"))
	NodeNew.name = "HevLib~Variables"
	var Gamespace_Canvas = load("res://HevLib/ui/core_scenes/_HevLib_Gamespace_Canvas.tscn").instance()
	CRoot.call_deferred("add_child",NodeNew)
	CRoot.call_deferred("add_child",Gamespace_Canvas)
	
	var keybind_interrupt = load("res://HevLib/scenes/keymapping/keybind_interrupt.tscn").instance()
	CRoot.call_deferred("add_child",keybind_interrupt)
	
	l("Ready")

func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	Debug.l("[%s V%s]: %s" % [title, version, msg])
