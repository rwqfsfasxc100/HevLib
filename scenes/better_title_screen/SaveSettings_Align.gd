extends CenterContainer


func _on_CenterContainer_visibility_changed():
#	var windowRes = OS.window_size
	var windowRes = Settings.getViewportSize()
	var windowX = windowRes.x
	var windowY = windowRes.y
	var windowSizeX = 716
	var windowSizeY = 600
	var setXOffset = (windowX-windowSizeX)/2
	var setYOffset = (windowY-windowSizeY)/2
	margin_left = setXOffset
	margin_top = setYOffset
