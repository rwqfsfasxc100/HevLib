extends MainLoop

func _notification(what):
	match what:
		NOTIFICATION_CRASH:
			breakpoint
