extends "res://CurrentGame.gd"

signal generic_notification(dictionary)

func send_notification(data:Dictionary):
	emit_signal("generic_notification",data)
