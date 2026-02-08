extends AcceptDialog

var current_mod = null


func _on_NoDownload_confirmed():
	if current_mod and current_mod.has_method("_downloaded_zip"):
		current_mod._downloaded_zip("","")
