extends HBoxContainer

var pointers = ModLoader._savedObjects[0]

var mod_id = ""
var mod_name = ""
var current_version = ""
var new_version = ""
var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"

var file = File.new()
var http = HTTPRequest.new()
onready var manager = get_parent().get_parent().get_parent().get_parent().get_parent()
func _ready():
	add_child(http)
	http.connect("request_completed",self,"update_return")
	$Popups/IgnorePopup.dialog_text = TranslationServer.translate("HEVLIB_CONFIRMATION_DIALOGUE_IGNORE_MOD_UPDATE") % [mod_name,new_version]
	$Popups/UpdatePopup.dialog_text = TranslationServer.translate("HEVLIB_CONFIRMATION_DIALOGUE_UPDATE_MOD") % [mod_name,current_version,new_version]

func _Ignore_pressed():
	$Popups/IgnorePopup.popup_centered()


func _Update_pressed():
	$Popups/UpdatePopup.popup_centered()

var display_wait_popup = true

func _ignore_confirmed():
	var currently_ignored = pointers.ConfigDriver.__get_value("ModMenu2","datastore","ignored_updates")
	if currently_ignored == null:
		pointers.ConfigDriver.__store_value("ModMenu2","datastore","ignored_updates",{})
	currently_ignored = pointers.ConfigDriver.__get_value("ModMenu2","datastore","ignored_updates")
	currently_ignored[mod_id] = new_version
	pointers.ConfigDriver.__store_value("ModMenu2","datastore","ignored_updates",currently_ignored)
	repos()
	Tool.remove(self)
var zip_folder = "user://cache/.Mod_Menu_2_Cache/updates/zip_cache/"

func _do_update():
	var dv = {"name":mod_name,"id":mod_id,"version":new_version,"container":self}
	manager.mods_to_download.append(dv)
	manager.start_updates()

func _update_confirmed():
	file.open(update_store,File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	var github = data[mod_id].get("github","")
	if github:
		http.download_file = zip_folder + data[mod_id]["file_name"]
		http.request(github)
		updating_percent = true
#		if github.ends_with("/"):
#			github.rstrip("/")
#		if not github.ends_with("/releases"):
#			github = github + "/releases"
#		pointers.Github.__get_github_release(github,zip_folder,self,true,"zip")
	else:
		var nod = manager.no_download_popup
		nod.dialog_text = TranslationServer.translate("HEVLIB_NO_DOWNLOAD_CONTENT") % mod_name
		nod.current_mod = self
		nod.call_deferred("popup_centered")
	if display_wait_popup:
		$Popups/WAIT.popup_centered()

func update_return(result, response_code,headers,body):
	var fp = http.download_file
	http.download_file = ""
	updating_percent = false
	_downloaded_zip(fp)

func _downloaded_zip(filepath):
	$Popups/WAIT.hide()
	file.open(update_store,File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	
	if mod_id in data:
		data.erase(mod_id)
	file.open(update_store,File.WRITE)
	file.store_string(JSON.print(data))
	file.close()
	repos()
	if filepath:
		pointers.FileAccess.__precache_mod_file(filepath)
	Tool.deferCallInPhysics(manager,"move_to_next_mod")
	Tool.remove(self)


func repos():
	var mods = get_parent().get_child_count()
	var pos = get_position_in_parent()
	if mods >= 2:
		if pos != 0:
			get_parent().get_child(0).get_node("Buttons/Ignore").grab_focus()
		else:
			get_parent().get_child(1).get_node("Buttons/Ignore").grab_focus()
	else:
		get_parent().get_parent().get_parent().get_node("ButtonContainer/Cancel/Button").grab_focus()
		get_parent().get_parent().get_parent().get_node("ButtonContainer/UpdateAll/Button").disabled = true
		get_parent().get_parent().get_parent().get_node("ButtonContainer/UpdateAll/Button").modulate = Color(0.7,0.7,0.7,1)
		get_parent().get_parent().get_parent().get_node("ButtonContainer/IgnoreAll/Button").disabled = true
		get_parent().get_parent().get_parent().get_node("ButtonContainer/IgnoreAll/Button").modulate = Color(0.7,0.7,0.7,1)

var frameCounter = 0

var download_text = ""

var updating_percent = false
var percent:float = 0
var bytes_downloaded: int = 0
var total_bytes: int = 0

func _physics_process(delta):
	if updating_percent:
		total_bytes = http.get_body_size()
		bytes_downloaded = http.get_downloaded_bytes()
		var frac = float(bytes_downloaded)/float(total_bytes)
		var f2 = frac * 100
		percent = f2
		print("HevLib GitHub Zip Downloader: Updating percent: %s%% | %s of %s" % [str(percent),bytes_downloaded,total_bytes])
		if bytes_downloaded > 0.0:
			_handle_downloaded_percent()

func _handle_downloaded_percent():
	if total_bytes > 0:
		_get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADING",percent,bytes_downloaded,total_bytes)
	else:
		_get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADING_ONLY_BYTES",percent,bytes_downloaded,total_bytes)

func _get_github_progress(response:String,percent:float,bytes_downloaded:int,total_bytes:int):
	var txt = ""
	frameCounter = 0
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
			manager.download_status = download_text
			prev_dt = download_text
		frameCounter += delta
