extends HBoxContainer

var DATA = {}

var formatted_data = {}

signal done(box)
signal pressed(data)

var pointers
var dir = Directory.new()
var unique_icon = ""
func boot():
	
	# Until rate limit passed
	# Maybe instead just use branch and fetch readme from there, bypassing extra api calls
	
	# Also rework fetch FS to use the following:
	# https://api.github.com/repos/company/project/contents/
	return
	
	var icon = get_node("ICON")
	var button = get_node("MOD_BUTTON")
	var name_label = get_node("MOD_BUTTON/VBoxContainer/NAME")
	var author_label = get_node("MOD_BUTTON/VBoxContainer/AUTHOR")
	var http = get_node("HTTPRequest")
	button.connect("pressed",self,"_pressed")
#	http.connect()
	var githubOwner = DATA.get("owner",{})
	name_label.text = DATA.get("name","")
	author_label.text = githubOwner.get("login","")
	var avatar_path = githubOwner.get("avatar_url","")
	unique_icon = filepath + githubOwner.get("node_id") + ".png"
	pointers = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
	if not dir.file_exists(unique_icon):
		http.download_file = unique_icon
		if avatar_path:
			make_request(avatar_path)
	else:
		icon.texture = pointers.FileAccess.__load_png(unique_icon)
	format(DATA.get("svn_url",""))
#	breakpoint
	finished()

func format(url:String):
	
	if url:
		var fs = pointers.Github.__get_github_filesystem(url,self)

func _github_filesystem_data(data):
	
	
	breakpoint

var filepath = "user://cache/.Mod_Menu_2_Cache/github_list/icon_cache/"
func make_request(path):
	if not dir.dir_exists(filepath):
		pointers.FolderAccess.__check_folder_exists(filepath)
	yield(CurrentGame.get_tree(),"idle_frame")
	get_node("HTTPRequest").request(path)


func finished():
	emit_signal("done",self)
func _pressed():
	emit_signal("pressed",formatted_data)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	get_node("ICON").texture = pointers.FileAccess.__load_png(unique_icon)
	get_node("HTTPRequest").download_file = ""
#	breakpoint
	
	
