extends Timer

func start_timer(MINUTES, useSecondsInstead = false):
	Debug.l("Timer started for %s minutes" % MINUTES)
	if useSecondsInstead == true:
		wait_time = MINUTES
	else:
		wait_time = MINUTES*60
	one_shot = true
	start()

func _on_Timer_timeout():
	Debug.l("Timer finished, deferring to parent node")
	get_parent().onTimerComplete()
