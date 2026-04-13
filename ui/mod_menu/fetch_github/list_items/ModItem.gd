extends HBoxContainer

var DATA = {}
var list
var formatted_data = {"readme":""}

signal done(box)
signal pressed(data)

var pointers
var dir = Directory.new()
var unique_icon = ""
var user_icon_uuid = ""
func boot():
	# Also rework fetch FS to use the following:
	# https://api.github.com/repos/company/project/contents/
	visible = false
	var githubOwner = DATA.get("owner",{})
	var avatar_path = githubOwner.get("avatar_url","")
	user_icon_uuid = githubOwner.get("node_id")
	unique_icon = filepath + user_icon_uuid + ".png"
	pointers = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
	if not dir.file_exists(unique_icon):
		list.add_uuid_to_queue(user_icon_uuid,avatar_path)
	else:
		set_icon_to(unique_icon)
	
	finished()

func add_mod():
	
	var icon = get_node("ICON")
	var button = get_node("MOD_BUTTON")
	var name_label = get_node("MOD_BUTTON/VBoxContainer/NAME")
	var author_label = get_node("MOD_BUTTON/VBoxContainer/AUTHOR")
	var http = get_node("HTTPRequest")
	button.connect("pressed",self,"_pressed")
	name_label.text = DATA.get("name","")
	var githubOwner = DATA.get("owner",{})
	author_label.text = githubOwner.get("login","")
	
	
	
	list.add_mod_count()
	visible = true

var filepath = "user://cache/.Mod_Menu_2_Cache/github_list/icon_cache/"
var readmePath = ""
func get_readme():
	yield(CurrentGame.get_tree(),"idle_frame")
	var branch = DATA.get("default_branch")
	var pathName = DATA.get("full_name")
	var path = "https://raw.githubusercontent.com/%s/refs/heads/%s/MOD_DESCRIPTION.txt" % [pathName,branch]
	readmePath = path
	get_node("HTTPRequest").request(path)
	
	
	pass

func finished():
	emit_signal("done",self)
func _pressed():
	emit_signal("pressed",formatted_data)


func icon_announcement(u):
	if u == user_icon_uuid:
		set_icon_to(unique_icon)
func set_icon_to(path):
	get_node("ICON").texture = pointers.FileAccess.__load_png(path)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS and response_code != 404:
		var data = body.get_string_from_utf8()
		format_description(data)
		
		add_mod()
	else:
		Tool.remove(self)

func format_description(data:String):
	var headerData = {}
	var textData = ""
	for line in data.split("\n"):
		if line.begins_with(";"):
			var d = line.split(";")[1].split("|")
			if d.size() == 2:
				headerData[d[0]] = d[1]
		else:
			if textData:
				textData += "\n" + line
	
	
	formatted_data["readme"] = textData

func _tree_entered():
	get_readme()
