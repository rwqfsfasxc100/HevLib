extends MarginContainer

# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

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
var pointers = ModLoader._savedObjects[0]

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
#	redisplay()
	Settings.connect("controlSchemeChaged", self, "redisplay")
	connect("resized", self, "center")
	
	connect("visibility_changed", self, "redisplay")


func center():
	rect_pivot_offset = rect_size / 2

func redisplay():
	recheck_availability()
	return
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
	if not is_inside_tree() or not is_visible_in_tree() or is_queued_for_deletion():
		return
	for key in keys.get_children():
		key.visible = false
		Tool.remove(key)
	var pv = get_parent().get_parent()
	var m = pv.mod
	var s = pv.section
	var a = pv.action
	var info = pointers.ConfigDriver.__get_value(m,s,a)
	var infosize = info.size()
	for rfs in range(infosize):
		if rfs:
			var sep = separator.instance()
			keys.add_child(sep)
		var ref = info[rfs]
		if typeof(ref) == TYPE_STRING:
			ref = [ref]
		var refsize = ref.size()
		for iv in range(refsize):
			
			var i = ref[iv]
			var type = OS.find_scancode_from_string(i)
			if i.begins_with("Mouse "):
				var d = mouseButtonDisplay.instance()
				d.key = int(i.split("Mouse ")[1])
				d.name = i
				keys.add_child(d)
			elif i.begins_with("JoyButton "):
				var d = gamepadKeyDisplay.instance()
				d.key = int(i.split("JoyButton ")[1])
				d.name = i
				keys.add_child(d)
			elif i.begins_with("JoyAxis "):
				var d = analogAxisDisplay.instance()
				var raw = i.split("JoyAxis ")[1]
				d.key = float(raw)
				d.raw = raw
				d.display_direction = true
				d.name = i
				keys.add_child(d)
			else:
				var d = keybindDisplay.instance()
				d.text = i
				d.name = i
				keys.add_child(d)
			if iv != ref.size() - 1:
				var splitLabel = Label.new()
				splitLabel.set_theme(load("res://hud/TNTRL-theme.tres"))
				splitLabel.size_flags_horizontal = SIZE_EXPAND_FILL
				splitLabel.size_flags_vertical = SIZE_EXPAND_FILL
				splitLabel.rect_size = Vector2(15,14)
				splitLabel.text = "+"
				keys.add_child(splitLabel)
		
		
