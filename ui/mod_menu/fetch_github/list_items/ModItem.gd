extends HBoxContainer

var DATA = {}
var list
var formatted_data = {"readme":"","header_data":{}}

signal done(box)
signal pressed(data,box)

var modPathPrefix = ""

var pointers
var dir = Directory.new()
var unique_icon = ""
var user_icon_uuid = ""
func boot():
	# Also rework fetch FS to use the following:
	# https://api.github.com/repos/company/project/contents/
	visible = false
	
	pointers = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
	
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	modPathPrefix = gameInstallDirectory.plus_file("mods")
	finished()

var file = File.new()
func add_mod():
	
	var icon = get_node("ICON")
	var button = get_node("MOD_BUTTON")
	var name_label = get_node("MOD_BUTTON/VBoxContainer/NAME")
	var author_label = get_node("MOD_BUTTON/VBoxContainer/AUTHOR")
	var http = get_node("HTTPRequest")
	button.connect("pressed",self,"_pressed")
	name_label.text = formatted_data["header_data"].get("MOD_NAME",DATA.get("name",""))
	var githubOwner = DATA.get("owner",{})
	author_label.text = githubOwner.get("login","")
	var avatar_path = githubOwner.get("avatar_url","")
	user_icon_uuid = githubOwner.get("node_id")
	unique_icon = filepath + user_icon_uuid + ".png"
	var icon_path : String = formatted_data["header_data"].get("MOD_ICON",avatar_path)
	if icon_path != avatar_path:
		unique_icon = filepath + "modicon_%s" % [hash(icon_path)] + ".png"
	if icon_path:
		if not dir.file_exists(unique_icon):
			http.download_file = unique_icon
			http.request(icon_path)
		else:
			mode += 1
			set_icon_to(unique_icon)
	
	get_downloads()
	
	list.add_mod_count()
	visible = true

var base_folder_path = "user://cache/.Mod_Menu_2_Cache/github_list/"
var filepath = base_folder_path + "icon_cache/"
var zip_path = base_folder_path + "downloaded_zips/"
var releases_cache_path = base_folder_path + "releases_cache.json"
var readmePath = ""
func get_readme():
	yield(CurrentGame.get_tree(),"idle_frame")
	var branch = DATA.get("default_branch")
	var pathName = DATA.get("full_name")
	var path = "https://raw.githubusercontent.com/%s/refs/heads/%s/MOD_DETAILS.txt" % [pathName,branch]
	readmePath = path
	get_node("HTTPRequest").request(path)
	
	
	pass

func finished():
	emit_signal("done",self)
func _pressed():
	emit_signal("pressed",formatted_data,self)
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
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	match mode:
		0:
			if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
				var data = body.get_string_from_utf8()
				format_description(data)
				var id = formatted_data["header_data"].get("MOD_ID","")
				if id in list.mod_ids:
					Tool.remove(self)
				else:
					add_mod()
			else:
				Tool.remove(self)
		1:
			if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
				set_icon_to(unique_icon)
				get_node("HTTPRequest").download_file = ""
		2:
			var data = {}
			if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
				data = JSON.parse(body.get_string_from_utf8()).result[0]["assets"][0]
				store_releases_cache(data)
			else:
				data = get_releases_cache()
			if data:
				this_zip_filename = zip_path + data.get("name","temp.zip")
				this_zip_url = data.get("browser_download_url")
				list.btn_to_download.disabled = false
			else:
				list.unavailable_mod()
				Tool.remove(self)
				list.btn_to_download.disabled = true

		3:
			if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
				var http = get_node("HTTPRequest")
				if "header_data" in formatted_data and "MOD_ZIP_NAME" in formatted_data["header_data"]:
					var folderPath = this_zip_filename.split(this_zip_filename.split("/")[this_zip_filename.split("/").size() - 1])[0]
					var newZipName = folderPath + formatted_data["header_data"]["MOD_ZIP_NAME"]
					dir.rename(this_zip_filename,newZipName)
					this_zip_filename = newZipName
					yield(get_tree(),"physics_frame")
				pointers.FileAccess.__copy_file(this_zip_filename,modPathPrefix)
				http.download_file = ""
				this_zip_filename = ""
				this_zip_url = ""
				list.WAIT.hide()
				list.btn_to_download.grab_focus()
				list.subtract_mod_count()
				list.select_first_mod()
				Tool.remove(self)
	mode += 1

var base_downloads_list = "https://api.github.com/repos/%s/releases"
func get_downloads():
	var downloads = base_downloads_list % [DATA.get("full_name")]
	$HTTPRequest.request(downloads)

func format_description(data:String):
	var headerData = {}
	var textData = ""
	for line in PoolStringArray(data.split("\n")):
		if line.begins_with(";"):
			var d = PoolStringArray(line.lstrip(";").split("|"))
			if d.size() == 2:
				headerData[d[0]] = d[1].strip_escapes()
		else:
			if textData:
				textData += "\n" + line
			else:
				textData = line
	
	
	formatted_data["readme"] = textData
	formatted_data["header_data"] = headerData

func download_this_mod():
	if not is_downloading and this_zip_filename and this_zip_url:
		var http = get_node("HTTPRequest")
		http.download_file = this_zip_filename
		is_downloading = true
		
		http.request(this_zip_url)
		list.btn_to_download.disabled = true

func store_releases_cache(data):
	var dt = {}
	if file.file_exists(releases_cache_path):
		file.open(releases_cache_path,File.READ)
		dt = JSON.parse(file.get_as_text()).result
		file.close()
	dt[DATA.get("full_name")] = data
	file.open(releases_cache_path,File.WRITE)
	file.store_string(JSON.print(dt))
	file.close()

func get_releases_cache():
	var out = {}
	file.open(releases_cache_path,File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	var fn = DATA.get("full_name")
	if fn in data:
		out = data[fn]
	return out

func _tree_entered():
	get_readme()
