extends MarginContainer

export  var limit = 2
export  var action = "ship_main_engine" setget _setAction
export  var keyHint = "HINT_KEY_PRESS"
export  var actionArray = PoolStringArray()

enum control{
	gamepad, 
	keyMouse, 
	auto, 
	key
}
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
export (PackedScene) var keybindDisplay
export (PackedScene) var gamepadKeyDisplay
export (PackedScene) var mouseButtonDisplay
export (PackedScene) var analogAxisDisplay
export (PackedScene) var separator

var defaultModulate
export  var tutorialModulate = Color(4, 4, 4, 1)
	
export  var exceptions = true
export  var tutorial = false
export (control) var forceScheme = control.auto
onready var keys = $Keys

func _input(event):
	if tutorial:
		if action and Input.is_action_pressed(action):
			modulate = tutorialModulate
		else:
			modulate = defaultModulate

func _setAction(to):
	action = to
	actionArray = PoolStringArray([to])
	redisplay()

func _ready():
	if not actionArray:
		actionArray.append(action)
	defaultModulate = modulate
	redisplay()
	Settings.connect("controlSchemeChaged", self, "redisplay")
	connect("resized", self, "center")
	
	connect("visibility_changed", self, "redisplay")


func center():
	rect_pivot_offset = rect_size / 2

func redisplay():
	if not is_visible_in_tree() or is_queued_for_deletion():
		return
	for c in keys.get_children():
		if c is Control:
			c.queue_free()
	var any = false
	var scheme = forceScheme
	if scheme == Settings.control.auto:
		scheme = Settings.controlScheme
		
	var haveKey = false
	var count = 0
	var add = []
	for a in actionArray:
		var binds = InputMap.get_action_list(a)
		for bind in binds:
			if count >= limit:
				break
			
			match scheme:
				Settings.control.keyMouse:
					if bind is InputEventMouseButton:
						var key = mouseButtonDisplay.instance()
						key.key = bind.button_index
						if key.rect_size.x > 0:
							add.append(key)
							count += 1
					if bind is InputEventKey and bind.scancode:
						var key = keybindDisplay.instance()
						key.text = bind.as_text()
						key.showExceptions = exceptions
						haveKey = true
						if key.rect_size.x > 0:
							add.append(key)
							count += 1
				control.key:
					if bind is InputEventKey:
						var key = keybindDisplay.instance()
						key.text = bind.as_text()
						key.showExceptions = exceptions
						haveKey = true
						if key.rect_size.x > 0:
							add.append(key)
							count += 1
				Settings.control.gamepad:
					if bind is InputEventJoypadButton:
						var key = gamepadKeyDisplay.instance()
						key.key = bind.button_index
						if key.rect_size.x > 0:
							add.append(key)
							count += 1
					if bind is InputEventJoypadMotion:
						var key = analogAxisDisplay.instance()
						key.key = bind.axis
						if key.rect_size.x > 0:
							add.append(key)
							count += 1
			
	var first = true
	for i in add:
		if tutorial and not first:
			var sep = separator.instance()
			keys.add_child(sep)

		keys.add_child(i)
		first = false
	
	var player = $Player
	var bob = $CenterContainer / C / Bobb
	if tutorial and haveKey:
		player.play("Plomp")
		player.seek(randf() * 3)
		bob.visible = true
		$CenterContainer.hint_tooltip = keyHint
	else:
		player.stop()
		bob.visible = false
		hint_tooltip = ""
	

func _visibility_changed():
	action = get_parent().get_parent().action
	var cfg_dta = get_parent().get_parent().get_parent().get_parent().CONFIG_DATA
	if "hint" in cfg_dta:
		keyHint = cfg_dta["hint"]

func recheck_availability():
	for key in keys.get_children():
		key.visible = false
		Tool.remove(key)
	var m = get_parent().get_parent().mod
	var s = get_parent().get_parent().section
	var a = get_parent().get_parent().action
	var info = pointers.ConfigDriver.__get_value(m,s,a)
#	var scheme = forceScheme
#	if scheme == Settings.control.auto:
#		scheme = Settings.controlScheme
#	var f = []
#	var binds = InputMap.get_action_list(a)
#	for bind in binds:
#		match scheme:
#			Settings.control.keyMouse:
#				if bind is InputEventMouseButton:
#					var key = mouseButtonDisplay.instance()
#					key.key = bind.button_index
#					if key.rect_size.x > 0:
#						f.append(key)
#
#				if bind is InputEventKey and bind.scancode:
#					var key = keybindDisplay.instance()
#					key.text = bind.as_text()
#					key.showExceptions = exceptions
#					if key.rect_size.x > 0:
#						f.append(key)
#			control.key:
#				if bind is InputEventKey:
#					var key = keybindDisplay.instance()
#					key.text = bind.as_text()
#					key.showExceptions = exceptions
#					if key.rect_size.x > 0:
#						f.append(key)
#			Settings.control.gamepad:
#				if bind is InputEventJoypadButton:
#					var key = gamepadKeyDisplay.instance()
#					key.key = bind.button_index
#					if key.rect_size.x > 0:
#						f.append(key)
#				if bind is InputEventJoypadMotion:
#					var key = analogAxisDisplay.instance()
#					key.key = bind.axis
#					if key.rect_size.x > 0:
#						f.append(key)
	for i in info:
		var type = OS.find_scancode_from_string(i)
		if i.begins_with("Mouse "):
			var d = mouseButtonDisplay.instance()
			d.key = int(i.split("Mouse ")[1])
			d.name = i
			keys.add_child(d)
#			breakpoint
		elif i.begins_with("JoyButton "):
			var d = gamepadKeyDisplay.instance()
			d.key = int(i.split("JoyButton ")[1])
			d.name = i
			keys.add_child(d)
#			breakpoint
		elif i.begins_with("JoyAxis "):
			var d = analogAxisDisplay.instance()
			d.key = abs(int(i.split("JoyAxis ")[1]))
			d.name = i
			keys.add_child(d)
#			breakpoint
		
		else:
			var d = keybindDisplay.instance()
			d.text = i
			d.name = i
			keys.add_child(d)
			
			
#			breakpoint
		
		
#		keys.add_child(i)
#	breakpoint
