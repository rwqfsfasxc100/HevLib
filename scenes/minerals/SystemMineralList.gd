extends "res://hud/SystemMineralList.gd"

func updateSystems(systems):
	for c in get_children():
		c.queue_free()
	var v = Label.new()
	add_child(v)
	
	for m in minerals:
		var i = mineralLabel.instance()
		
		i.modulate = CurrentGame.specificMineralColors[m] if m in CurrentGame.specificMineralColors else unknownColor
		i.mineral = m
		if m in CurrentGame.specificMineralColors:
			i.connect("focus_entered", self, "focusOnMineral", [m])
			if i.has_method("highlightChange"):
				connect("mineralFocusChanged", i, "highlightChange")
		add_child(i)
	if true:
		var i = mineralLabel.instance()
		i.text = "HUD_MIN_PRICE"
		add_child(i)
		
	observeMass = []
	
	for s in systems:
		var ref = systems[s].ref
		var rlock = ref
		if Tool.claim(rlock):
			if "system" in ref and ref.system:
				ref = ref.system
			if "mineralTargetting" in ref and ref.mineralTargetting:
				var l = systemLabel.instance()
				l.text = systems[s].name
				add_child(l)
				var scroll = ScrollContainer.new()
				scroll.set_script(load("res://enceladus/ScrollWithAnalog.gd"))
				for m in minerals:
					var i = toggleBox.instance()
					i.connect("toggled", self, "toggle", [ref, m])
					i.connect("focus_entered", self, "focusOnMineral", [m])
					if ref.has_method("getMineralInTarget"):
						observeMass.append({
							"ref": ref, 
							"mineral": m, 
							"node": i
						})
					if ref.has_method("hasMineralEnabled"):
						i.pressed = ref.hasMineralEnabled(m)
					if "onlyMinerals" in ref and ref.onlyMinerals:
						if not CurrentGame.traceMinerals.has(m):
							i.disabled = true
							i.modulate = modulateDisabled
					scroll.add_child(i)
				add_child(scroll)
				var i = priceBox.instance()
				i.connect("valueChanged", self, "value", [ref])
				if ref.has_method("getMinValue"):
					i.value = ref.getMinValue()
				add_child(i)
				if "onlyMinerals" in ref and ref.onlyMinerals:
					i.disabled = true
				if "oreValueFilter" in ref:
					i.disabled = not ref.oreValueFilter
			Tool.release(rlock)
	focusOnMineral(defaultFocus)
