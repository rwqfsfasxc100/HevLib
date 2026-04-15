extends VBoxContainer

const prevent_load = false

export var path_to_httprequest = NodePath("../../../../api_fetcher")
export var path_to_downloader = NodePath("../../../../download_files")
export var path_to_root = NodePath("../../../..")
export var path_to_download_btn = NodePath("../Info/HBoxContainer/DownloadMod")
onready var http : HTTPRequest = get_node_or_null(path_to_httprequest)
onready var downloader : HTTPRequest = get_node_or_null(path_to_downloader)
onready var parent = get_node_or_null(path_to_root)
onready var btn_to_download = get_node_or_null(path_to_download_btn)

const topic_url_base = "https://api.github.com/search/repositories?q=topic:%s"
const topic_dv = "delta-v-rings-of-saturn"
var icon_folder_path = "user://cache/.Mod_Menu_2_Cache/github_list/icon_cache/"

onready var count = $Header/Count
onready var list = $Mods/ScrollContainer/ListMods
onready var info = get_node_or_null(NodePath("../Info"))
onready var rich = info.get_node("RichTextLabel")

onready var WAIT = parent.get_node_or_null(NodePath("WAIT"))

var mod_item = load("res://HevLib/ui/mod_menu/fetch_github/list_items/ModItem.tscn")
var file = File.new()
signal icon_downloaded(uuid)

onready var pointers = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
onready var mod_ids = pointers.ManifestV2.__get_mod_ids()

var mod_list_cache = "user://cache/.Mod_Menu_2_Cache/github_list/list_cache.json"
func _ready():
	if prevent_load:
		return
	
	downloader.connect("request_completed",self,"download_complete")
	count.text = TranslationServer.translate("HEVLIB_GITHUBMODS_COUNT") % [0]
	btn_to_download.disabled = true
	http.connect("request_completed",self,"request_complete")
	file.open(mod_list_cache,File.READ)
	var dt = JSON.parse(file.get_as_text(true)).result
	file.close()
	if dt.size():
		fill_in_mods(dt)
	else:
		http.request(topic_url_base % [topic_dv])
	
	

var mod_count = 0
func request_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8()).result
	if json:
		var dt = json.get("items",[])
		file.open(mod_list_cache,File.WRITE)
		file.store_string(JSON.print(dt))
		file.close()
		fill_in_mods(dt)

func add_mod_count():
	mod_count += 1
	count.text = TranslationServer.translate("HEVLIB_GITHUBMODS_COUNT") % mod_count

func subtract_mod_count():
	mod_count -= 1
	count.text = TranslationServer.translate("HEVLIB_GITHUBMODS_COUNT") % mod_count

func fill_in_mods(items : Array):
	for item in items:
		var box = mod_item.instance()
		box.DATA = item
		box.list = self
		connect("icon_downloaded",box,"icon_announcement")
		box.connect("done",self,"add_box")
		box.boot()

func add_box(box):
	box.connect("pressed",self,"_mod_selected")
	list.add_child(box)
	select_first_mod()

var last_uuid = ""

func download_complete(result, response_code, headers, body):
	emit_signal("icon_downloaded",last_uuid)
	

var current_button = null
func _mod_selected(mod,btn):
	rich.clear()
	rich.parse_bbcode(mod["readme"])
	btn_to_download.disabled = (btn.this_zip_filename == "" or btn.this_zip_url == "")
	current_button = btn

func select_first_mod():
	yield(CurrentGame.get_tree(),"physics_frame")
	var v = list.get_children()
	if list:
		var first = v[0]
		if first:
			first._pressed()
	else:
		rich.clear()
		btn_to_download.disabled = true
		current_button = null
	

func _on_DownloadMod_pressed():
	if current_button:
		current_button.download_this_mod()
		WAIT.show_menu()
