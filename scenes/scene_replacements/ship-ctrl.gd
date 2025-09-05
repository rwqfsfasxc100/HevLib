extends "res://ships/ship-ctrl.gd"

var MPUs = []
var HUDs = []

func _ready():
	var mname = self.shipName
	if !self.cutscene and self.isPlayerControlled():
		var children = get_children()
		for child in children:
			var scriptobj = child.get_script()
			if scriptobj != null:
				var script = scriptobj.get_path()
				if script == "res://hud/Hud.gd":
					child.set_script(scriptobj)
				if script == "res://ships/modules/MineralProcessingUnit.gd":
					child.set_script(scriptobj)
		breakpoint

#func _process(delta):
#	if !self.cutscene and self.isPlayerControlled():
#		breakpoint

func _input(event):
	if !self.cutscene and self.isPlayerControlled():
		breakpoint
