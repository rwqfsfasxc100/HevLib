extends HBoxContainer

var DATA = {}
var list
var formatted_data = {"readme":"","header_data":{}}

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
	
	pointers = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
	
	
	finished()

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

	
	list.add_mod_count()
	visible = true

var filepath = "user://cache/.Mod_Menu_2_Cache/github_list/icon_cache/"
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
	emit_signal("pressed",formatted_data)


func icon_announcement(u):
	if u == user_icon_uuid:
		set_icon_to(unique_icon)
func set_icon_to(path):
	get_node("ICON").texture = pointers.FileAccess.__load_png(path)

var mode = 0
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	match mode:
		0:
			if result == HTTPRequest.RESULT_SUCCESS and response_code != 404:
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
			if result == HTTPRequest.RESULT_SUCCESS and response_code != 404:
				set_icon_to(unique_icon)
				get_node("HTTPRequest").download_file = ""
	mode += 1

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

func _tree_entered():
	get_readme()
