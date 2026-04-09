extends VBoxContainer

export var path_to_httprequest = NodePath("../../../../HTTPRequest")
export var path_to_root = NodePath("../../../..")
onready var http : HTTPRequest = get_node_or_null(path_to_httprequest)
onready var parent = get_node_or_null(path_to_root)

const topic_url_base = "https://api.github.com/search/repositories?q=topic:%s"
const topic_dv = "delta-v-rings-of-saturn"

onready var count = $Header/Count
onready var list = $Mods/ScrollContainer/ListMods

var mod_item = load("res://HevLib/ui/mod_menu/fetch_github/list_items/ModItem.tscn")

func _ready():
	http.connect("request_completed",self,"request_complete")
	http.request(topic_url_base % [topic_dv])
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
		box.connect("done",self,"add_box")
		box.boot()

func add_box(box):
	box.connect("pressed",self,"_mod_selected")
	list.add_child(box)
