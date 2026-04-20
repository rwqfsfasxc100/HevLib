extends Label

func clear():
	text = "HEVLIB_PLEASE_WAIT"
	set_process(false)
var download_text = ""
var current_mod_text = ""
var frameCounter = 0.0

func _get_github_progress(response:String,percent:float,bytes_downloaded:int,total_bytes:int):
	var txt = ""
	frameCounter = 0.0
	match response:
		"HEVLIB_GITHUB_PROGRESS_WAITING_ON_RESPONSE":
			txt = TranslationServer.translate(response)
		"HEVLIB_GITHUB_PROGRESS_ZIP_FOUND_AND_REQUESTING":
			txt = TranslationServer.translate(response)
		"HEVLIB_GITHUB_PROGRESS_DOWNLOADED_FILE":
			txt = TranslationServer.translate(response)
		"HEVLIB_GITHUB_PROGRESS_DOWNLOADING":
			var c = float(bytes_downloaded)
			var t = float(total_bytes)
			var c_label = "HEVLIB_SIZE_LABEL_BYTES"
			var t_label = "HEVLIB_SIZE_LABEL_BYTES"
			if c > 1000:
				c /= 1024
				c_label = "HEVLIB_SIZE_LABEL_KILOBYTES"
				if c > 1000:
					c /=1024
					c_label = "HEVLIB_SIZE_LABEL_MEGABYTES"
			if t > 1000:
				t /= 1024
				t_label = "HEVLIB_SIZE_LABEL_KILOBYTES"
				if t > 1000:
					t /=1024
					t_label = "HEVLIB_SIZE_LABEL_MEGABYTES"
			txt = TranslationServer.translate(response) % [percent,c,TranslationServer.translate(c_label),t,TranslationServer.translate(t_label)]
		"HEVLIB_GITHUB_PROGRESS_DOWNLOADING_ONLY_BYTES":
			var c = float(bytes_downloaded)
			var c_label = "HEVLIB_SIZE_LABEL_BYTES"
			if c > 1000:
				c /= 1024
				c_label = "HEVLIB_SIZE_LABEL_KILOBYTES"
				if c > 1000:
					c /=1024
					c_label = "HEVLIB_SIZE_LABEL_MEGABYTES"
			txt = TranslationServer.translate(response) % [c,TranslationServer.translate(c_label)]
	if txt != "":
		download_text = txt

var prev_dt = ""
func _process(delta):
	if is_visible_in_tree():
		if frameCounter > 10:
			download_text = ""
		if download_text != prev_dt:
			text = current_mod_text + "\n\n" + download_text
			prev_dt = download_text
		frameCounter += delta
