extends VBoxContainer

const prevent_load = true

export var path_to_httprequest = NodePath("../../../../api_fetcher")
export var path_to_downloader = NodePath("../../../../download_files")
export var path_to_root = NodePath("../../../..")
onready var http : HTTPRequest = get_node_or_null(path_to_httprequest)
onready var downloader : HTTPRequest = get_node_or_null(path_to_downloader)
onready var parent = get_node_or_null(path_to_root)

const topic_url_base = "https://api.github.com/search/repositories?q=topic:%s"
const topic_dv = "delta-v-rings-of-saturn"

onready var count = $Header/Count
onready var list = $Mods/ScrollContainer/ListMods
onready var info = get_node_or_null(NodePath("../Info"))

var mod_item = load("res://HevLib/ui/mod_menu/fetch_github/list_items/ModItem.tscn")

signal icon_downloaded(uuid)
func _ready():
	if prevent_load:
		return
	http.connect("request_completed",self,"request_complete")
	http.request(topic_url_base % [topic_dv])
	downloader.connect("request_completed",self,"download_complete")
	count.text = TranslationServer.translate("HEVLIB_GITHUBMODS_COUNT") % [0]


func request_complete(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8()).result
	if json:
		count.text = TranslationServer.translate("HEVLIB_GITHUBMODS_COUNT") % [json.get("total_count",0)]
		fill_in_mods(json.get("items",[]))

func fill_in_mods(items : Array):
	for item in items:
		var box = mod_item.instance()
		box.DATA = item
		box.list = self
		connect("icon_downloaded",box,"icon_announcement")
		box.connect("done",self,"add_box")
		box.boot()
	yield(CurrentGame.get_tree(),"idle_frame")
	process_icons()

func add_box(box):
	box.connect("pressed",self,"_mod_selected")
	list.add_child(box)

var icon_folder_path = "user://cache/.Mod_Menu_2_Cache/github_list/icon_cache/"
var icons_to_fetch = {}
func add_uuid_to_queue(uuid,path):
	if not uuid in icons_to_fetch:
		icons_to_fetch[uuid] = path

var last_uuid = ""
func process_icons():
	if icons_to_fetch:
		var i = icons_to_fetch.keys().pop_front()
		var path = icons_to_fetch[i]
		icons_to_fetch.erase(i)
		last_uuid = i
		downloader.download_file = icon_folder_path + i + ".png"
		downloader.request(path)

func download_complete(result, response_code, headers, body):
	emit_signal("icon_downloaded",last_uuid)
	if icons_to_fetch:
		process_icons()
	else:
		downloader.download_file = ""
		last_uuid = ""

func _mod_selected(mod):
	info.get_node("Markdown")._set_markdown_text(mod["readme"])
	
	pass
