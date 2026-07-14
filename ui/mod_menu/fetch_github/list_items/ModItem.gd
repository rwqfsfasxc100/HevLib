extends HBoxContainer

var DATA = {}
var list
var formatted_data = {"readme":"","header_data":{}}

signal done(box)
signal pressed(data,box)

onready var http = get_node("HTTPRequest")

var pointers = ModLoader._savedObjects[0]
var dir = Directory.new()
var unique_icon = ""
var user_icon_uuid = ""
func boot():
	# Also rework fetch FS to use the following:
	# https://api.github.com/repos/company/project/contents/
	visible = false
	
	finished()

var file = File.new()
func _tree_entered():
	get_readme()

var base_folder_path = "user://cache/.Mod_Menu_2_Cache/github_list/"
var filepath = base_folder_path + "icon_cache/"
var zip_path = base_folder_path + "downloaded_zips/"
var releases_cache_path = base_folder_path + "releases_cache.json"
var update_check_path = base_folder_path + "update_check_cache.json"
var readmePath = ""
func get_readme():
	yield(CurrentGame.get_tree(),"idle_frame")
	http.connect("request_completed",self,"_request_completed")
	add_mod()

func add_mod():
	var icon = get_node("ICON")
	var button = get_node("MOD_BUTTON")
	var name_label = get_node("MOD_BUTTON/VBoxContainer/NAME")
	var author_label = get_node("MOD_BUTTON/VBoxContainer/AUTHOR")
	button.connect("pressed",self,"_pressed")
	
	var mod_id = DATA["formatted"]["header_data"].get("MOD_ID")
	
	var this_name = DATA["formatted"]["header_data"].get("MOD_NAME")
	if not this_name:
		this_name = mod_id
	name_label.text = DATA["formatted"]["header_data"].get("MOD_NAME")
	var author = DATA["formatted"]["header_data"].get("AUTHOR")
	author_label.text = author
	unique_icon = filepath + mod_id + ".png"
	if not file.file_exists(unique_icon) or ((Time.get_unix_time_from_system() - file.get_modified_time(unique_icon)) < (7 * 3600)):
		var icon_url = DATA.get("icon_path","")
		if icon_url:
			$iconrequest.download_file = unique_icon
			$iconrequest.connect("request_completed",self,"icon_requested")
			$iconrequest.request(icon_url)
	else:
		set_icon_to(unique_icon)
	this_zip_url = DATA.get("zip_filename","")
	if this_zip_url:
		this_zip_filename = zip_path + DATA["formatted"]["header_data"].get("MOD_ZIP_NAME",this_zip_url.split("/")[-1])
	list.add_mod_count()
	visible = true

func finished():
	emit_signal("done",self)
func _pressed():
	emit_signal("pressed",DATA["formatted"]["readme"],self)
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	$MOD_BUTTON.grab_focus()


func icon_announcement(u):
	if u == user_icon_uuid:
		set_icon_to(unique_icon)
func set_icon_to(path):
	get_node("ICON").texture = pointers.FileAccess.__load_png(path)

var is_downloading = false
var this_zip_filename = ""
var this_zip_url = ""
var mode = 0

var base_downloads_list = "https://api.github.com/repos/%s/releases"

func download_this_mod():
	if not is_downloading and this_zip_filename and this_zip_url:
		http.download_file = this_zip_filename
		is_downloading = true
		list.WAIT_LABEL.set_process(true)
		http.request(this_zip_url)
		list.btn_to_download.disabled = true

var percent:float = 0
var bytes_downloaded: int = 0
var total_bytes: int = 0
func _physics_process(delta):
	if is_downloading:
		total_bytes = http.get_body_size()
		bytes_downloaded = http.get_downloaded_bytes()
		var frac = float(bytes_downloaded)/float(total_bytes)
		var f2 = frac * 100
		percent = f2
		print("HevLib GitHub Zip Downloader: Updating percent: %s%% | %s of %s" % [str(percent),bytes_downloaded,total_bytes])
		if bytes_downloaded > 0.0:
			if list.WAIT_LABEL.has_method("_get_github_progress"):
				if total_bytes > 0:
					list.WAIT_LABEL._get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADING",percent,bytes_downloaded,total_bytes)
				else:
					list.WAIT_LABEL._get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADING_ONLY_BYTES",percent,bytes_downloaded,total_bytes)
			
			
			pass


func _request_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		pointers.FileAccess.__precache_mod_file(this_zip_filename)
		http.download_file = ""
		this_zip_filename = ""
		this_zip_url = ""
		list.WAIT.hide()
		list.WAIT_LABEL.clear()
		list.btn_to_download.disabled = false
		is_downloading = false
		list.btn_to_download.grab_focus()
		list.subtract_mod_count()
		list.select_first_mod()
		Tool.remove(self)


func icon_requested(result, response_code, headers, body):
	if response_code == 200:
		set_icon_to(unique_icon)
