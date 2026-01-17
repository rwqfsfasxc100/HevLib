extends Popup

func restart_cancel():
	hide()

func _restart():
	var path = OS.get_executable_path()
	var args = OS.get_cmdline_args()
	var pid = OS.execute(path, args, false)
	OS.kill(OS.get_process_id())
	
#	Settings.restartGame()

func _exit():
	OS.kill(OS.get_process_id())

