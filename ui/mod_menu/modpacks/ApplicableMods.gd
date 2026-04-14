extends VBoxContainer


onready var wait_popup = get_node_or_null(NodePath("../../../WAIT"))
onready var wait_label = get_node_or_null(NodePath("../../../WAIT/PanelContainer/Button/Label"))
onready var import_button = get_node_or_null(NodePath("../Buttons/Import"))
onready var applicable_list = $ScrollContainer/VBoxContainer
onready var applicable_label = preload("res://HevLib/ui/mod_menu/modpacks/ApplicableModLabel.tscn")
onready var root = get_node_or_null("../../..")
var applicable_mods = {}
var exported_mods = []

var pointers
var modPathPrefix = ""
func _ready():
	yield(CurrentGame.get_tree(),"idle_frame")
	pointers = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
	var mods = pointers.ManifestV2.__get_mod_data()["mods"]
	for m in mods:
		var mod = mods[m]
		if mod["manifest"]["has_manifest"]:
			var manifest = mod["manifest"]["manifest_data"]
			if "HEVLIB_GITHUB" in manifest.get("links",{}):
				var github = manifest["links"]["HEVLIB_GITHUB"].get("URL","")
				if github:
					var info = manifest["mod_information"]
					var id = info["id"]
					var mname = info["name"]
					applicable_mods[id] = {"name":mname,"github_url":github}
					exported_mods.append(id)
	for mod in applicable_mods:
		var m = applicable_mods[mod]
		var label = applicable_label.instance()
		label.set_text(m["name"])
		label.modname = mod
		label.data = m.duplicate(true)
		label.parent = self
		label.name = str(hash(mod))
		applicable_list.add_child(label)
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	modPathPrefix = gameInstallDirectory.plus_file("mods")
	

func toggled(id,how):
	if how:
		if not id in exported_mods:
			exported_mods.append(id)
	else:
		if id in exported_mods:
			exported_mods.erase(id)

func make_valid_modpack() -> Dictionary:
	var out : Dictionary = {}
	for mod in exported_mods:
		var modData = applicable_mods[mod]
		out[mod] = modData
	return out

onready var openPack = get_node_or_null(NodePath("../../../OpenPack"))
onready var savePack = get_node_or_null(NodePath("../../../SavePack"))

func _on_Export_pressed():
	var directory = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","modpack_last_path")
	if directory:
		savePack.set_current_dir(directory)
	savePack.set_current_file("modpack.dvmodpack")
	savePack.popup_centered()

var file = File.new()

func _on_SavePack_file_selected(path):
	var directory = path.split(path.split("/")[path.split("/").size() - 1])[0]
	pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","modpack_last_path",directory)
	var data = JSON.print(make_valid_modpack())
	file.open(path,File.WRITE)
	file.store_string(data)
	file.close()

var handling = false
func _on_OpenPack_file_selected(path):
	if not handling:
		if not root.visible:
			root.show_menu()
		handling = true
		var directory = path.split(path.split("/")[path.split("/").size() - 1])[0]
		pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","modpack_last_path",directory)
		file.open(path,File.READ)
		var data = JSON.parse(file.get_as_text()).result
		file.close()
		start_downloads(data)
		
func _on_Import_pressed():
	var directory = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","modpack_last_path")
	if directory:
		openPack.set_current_dir(directory)
	openPack.set_current_file("modpack.dvmodpack")
	openPack.popup_centered()

func hide_all():
	openPack.hide()
	savePack.hide()
	root.cancel()




var already_installed = 0
func start_downloads(data):
	var currently_installed = pointers.ManifestV2.__get_mod_ids()
	var to_download = []
	already_installed = 0
	current_mod = 0
	for mod in data:
		if not mod in currently_installed:
			var dv = data[mod].duplicate(true)
			dv.merge({"id":mod})
			to_download.append(dv)
		else:
			already_installed += 1
	total_downloads = 0
	if to_download:
		mods_to_download = to_download.duplicate(true)
		wait_popup.popup_centered()
		total_downloads = mods_to_download.size()
		handle_downloads()
var total_downloads = 0
var current_mod = 0
var zip_folder = "user://cache/.Mod_Menu_2_Cache/updates/zip_cache/"
var mods_to_download = []
func handle_downloads():
	var this_mod = mods_to_download.pop_front()
	var github = this_mod.get("github_url","")
	if github:
		if github.ends_with("/"):
			github.rstrip("/")
		if not github.ends_with("/releases"):
			github = github + "/releases"
		current_mod += 1
		
		var id = this_mod.get("id","Missing ID")
		var mdname = this_mod.get("name",id)
		current_mod_text = TranslationServer.translate("HEVLIB_MODPACK_DOWNLOADING") % [current_mod,total_downloads,mdname,id,already_installed]
		pointers.Github.__get_github_release(github,zip_folder,self,true,"zip")
var has_updated_store = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
var f = File.new()
func _downloaded_zip(file, filepath):
	if filepath and modPathPrefix:
		pointers.FileAccess.__copy_file(filepath,modPathPrefix)
	f.open(has_updated_store,File.WRITE)
	f.store_string("1")
	f.close()
	if mods_to_download:
		Tool.deferCallInPhysics(self,"handle_downloads")
	else:
		import_button.grab_focus()
		wait_popup.hide()
		handling = true

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
	if wait_popup.is_visible_in_tree():
		if frameCounter > 10:
			download_text = ""
		if download_text != prev_dt:
			wait_label.text = current_mod_text + "\n\n" + download_text
			prev_dt = download_text
		frameCounter += delta
