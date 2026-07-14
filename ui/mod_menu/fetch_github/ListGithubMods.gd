extends VBoxContainer

const prevent_load = false

export var path_to_httprequest = NodePath("../../../../api_fetcher")
export var path_to_downloader = NodePath("../../../../download_files")
export var path_to_root = NodePath("../../../..")
export var path_to_download_btn = NodePath("../Info/HBoxContainer/DownloadMod")
export var path_to_unavailablePopup = NodePath("../../../../Unavailable")
onready var http : HTTPRequest = get_node_or_null(path_to_httprequest)
onready var downloader : HTTPRequest = get_node_or_null(path_to_downloader)
onready var parent = get_node_or_null(path_to_root)
onready var btn_to_download = get_node_or_null(path_to_download_btn)
onready var unavailable_diag = get_node_or_null(path_to_unavailablePopup)

const topic_url_base = "https://api.github.com/search/repositories?q=topic:delta-v-rings-of-saturn&per_page=%d&page=%d"
const topic_url_database = "https://raw.githubusercontent.com/rwqfsfasxc100/dv_update_database/refs/heads/main/github_fetcher_store/compiled_topic_store.json"
const page_size = 100
var current_page = 1
var icon_folder_path = "user://cache/.Mod_Menu_2_Cache/github_list/icon_cache/"

onready var count = $Header/Count
onready var list = $Mods/ScrollContainer/ListMods
onready var info = get_node_or_null(NodePath("../Info"))
onready var rich = info.get_node("ScrollContainer/VBoxContainer/RichTextLabel")

onready var WAIT = parent.get_node_or_null(NodePath("WAIT"))
onready var WAIT_LABEL = WAIT.get_node_or_null(NodePath("PanelContainer/Button/VBoxContainer/wait_label"))

var mod_item = load("res://HevLib/ui/mod_menu/fetch_github/list_items/ModItem.tscn")
var file = File.new()
signal icon_downloaded(uuid)

var pointers = ModLoader._savedObjects[0]
var mod_ids:Array = pointers.ManifestV2.__get_mod_ids()

var mod_list_cache = "user://cache/.Mod_Menu_2_Cache/github_list/list_cache.json"
func _ready():
	if prevent_load:
		return
	var disabledModlets:Dictionary = pointers.ManifestV2.__get_disabled_modlets()
	for i in disabledModlets:
		mod_ids.append(disabledModlets[i])
	downloader.connect("request_completed",self,"download_complete")
	count.text = TranslationServer.translate("HEVLIB_GITHUBMODS_COUNT") % [0]
	btn_to_download.disabled = true
	http.connect("request_completed",self,"request_complete")
	var dt = {}
	if file.file_exists(mod_list_cache):
		var fileAge = Time.get_unix_time_from_system() - file.get_modified_time(mod_list_cache)
		if fileAge < int(floor(0.5 * 3600)):
			file.open(mod_list_cache,File.READ)
			dt = JSON.parse(file.get_as_text(true)).result
			file.close()
			if typeof(dt) != TYPE_DICTIONARY:
				dt = {}
	if dt.size():
		fill_in_mods(dt)
	else:
		http.request(topic_url_database)
#		http.request(topic_url_base % [page_size,current_page])
	
	

var mod_count = 0

var needed_pages = 0
var mods_found_from_api = 0
func request_complete(result, response_code, headers, body):
	if response_code != 200:
		if file.file_exists(mod_list_cache):
			file.open(mod_list_cache,File.READ)
			var dt = JSON.parse(file.get_as_text()).result
			file.close()
			if typeof(dt) != TYPE_DICTIONARY:
				dt = {}
			fill_in_mods(dt)
	else:
		var string = body.get_string_from_utf8()
		var json = JSON.parse(string).result
		if json:
			file.open(mod_list_cache,File.WRITE)
			file.store_string(JSON.print(json))
			file.close()
			fill_in_mods(json)
			
func add_mod_count():
	mod_count += 1
	count.text = TranslationServer.translate("HEVLIB_GITHUBMODS_COUNT") % mod_count

func subtract_mod_count():
	mod_count -= 1
	count.text = TranslationServer.translate("HEVLIB_GITHUBMODS_COUNT") % mod_count

func fill_in_mods(items : Dictionary):
	var current_ids = pointers.ManifestV2.__get_mod_ids()
	for mod_id in items:
		if mod_id and not mod_id in current_ids:
			var item = items[mod_id]
			var box = mod_item.instance()
			box.DATA = item
			box.list = self
			connect("icon_downloaded",box,"icon_announcement")
			box.connect("done",self,"add_box")
			box.boot()

func add_box(box):
	box.connect("pressed",self,"_mod_selected")
	list.add_child(box)
	

var last_uuid = ""

func download_complete(result, response_code, headers, body):
	emit_signal("icon_downloaded",last_uuid)
	

var current_button = null
func _mod_selected(mod,btn):
	rich.clear()
	rich.parse_bbcode(mod)
	btn_to_download.disabled = (btn.this_zip_filename == "" or btn.this_zip_url == "")
	current_button = btn

func select_first_mod():
	yield(CurrentGame.get_tree().create_timer(0.1),"timeout")
	var v = list.get_children()
	if v:
		var first = v[0]
		if first:
			first._pressed()
	else:
		rich.clear()
		btn_to_download.disabled = true
		current_button = null
		$Footer/Close.grab_focus()
	

func _on_DownloadMod_pressed():
	if current_button:
		current_button.download_this_mod()
		WAIT.show_menu()

func unavailable_mod():
	unavailable_diag.popup_centered()
