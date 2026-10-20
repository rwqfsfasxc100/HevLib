extends "res://menu/TitleMenu.gd"

onready var cam:Camera2D = get_node_or_null("../../WorldCenter/Camera2D")

func _input(event:InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		var mouseGlobal = Tool.globalMousePositionFor(cam)
		var space_state = cam.get_world_2d().direct_space_state
		var psq = Physics2DShapeQueryParameters.new()
		var pss = CircleShape2D.new()
		pss.radius = 1
		psq.set_shape(pss)
		psq.transform = Transform2D(0.0, mouseGlobal)
		var hits = space_state.intersect_shape(psq)
		if hits:
			var delta:float = (1.0 / Settings.getFps())
			for hit in hits:
				var col = hit.collider
				if col.has_method("applyKineticDamage") and Tool.claim(col):
					if "splitEnergyThreshold" in col:
						var ke_needed = ((col.splitEnergyThreshold + 100) - col.hardness * (60.0 / (1.0 / delta))) / col.kineticDamageScale
						col.applyKineticDamage(ke_needed, mouseGlobal)
					else:
						col.applyKineticDamage(100000, mouseGlobal)
					if col.has_method("applyEnergyDamage"):
						col.applyEnergyDamage(100000, mouseGlobal,delta)
					Tool.release(col)
