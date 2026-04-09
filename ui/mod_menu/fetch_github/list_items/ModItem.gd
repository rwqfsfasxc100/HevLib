extends HBoxContainer

var DATA = {}

signal done(box)

onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")

func boot():
	var icon = get_node("ICON")
	var button = get_node("MOD_BUTTON")
	var name_label = get_node("MOD_BUTTON/VBoxContainer/NAME")
	var author_label = get_node("MOD_BUTTON/VBoxContainer/AUTHOR")
	var http = get_node("HTTPRequest")
#	http.connect()
	var githubOwner = DATA.get("owner",{})
	name_label.text = DATA.get("name","")
	author_label.text = githubOwner.get("login","")
	var avatar_path = githubOwner.get("avatar_url","")
	if avatar_path:
		make_request(avatar_path)
#	breakpoint
	finished()


func make_request(path):
	yield(CurrentGame.get_tree(),"idle_frame")
	get_node("HTTPRequest").request_raw(path)


func finished():
	emit_signal("done",self)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	
	
	
	breakpoint
	
	
	
