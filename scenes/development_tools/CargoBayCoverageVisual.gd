tool
extends CanvasLayer

export var editor_only = true
var count = 0
func _physics_process(delta):
	if Engine.is_editor_hint() or not editor_only:
		count += 1
		if count > 5:
			count = 0
			var rect = $ColorRect
			var ref = $Offset/ReferenceRect
			var offset = $Offset
			var parent = get_parent()
			if parent.has_method("getConfig"):
				if "cargoHoldArea" in parent:
					rect.rect_position = parent.cargoHoldArea.position
					rect.rect_size = parent.cargoHoldArea.size
					if "cargoHoldOffset" in parent:
						ref.rect_size = parent.cargoHoldArea.size
						ref.rect_position = parent.cargoHoldOffset# + Vector2(-130,-282)
	else:
		Tool.remove(self)
