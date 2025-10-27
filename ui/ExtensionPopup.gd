extends "res://menu/ExtensionPopup.gd"

func _on_Extensions_pressed():
	var size = Settings.getViewportSize()
	rect_size = size
	._on_Extensions_pressed()
