extends VBoxContainer

onready var nameplate = $NAME
onready var description_label = $DESC/ScrollContainer/VBoxContainer/DESCRIPTION
onready var author_label = $DESC/ScrollContainer/VBoxContainer/AUTHOR
onready var credits_label = $DESC/ScrollContainer/VBoxContainer/CREDITS
onready var credits_header = $DESC/ScrollContainer/VBoxContainer/CHEADER
onready var desc_button = $DESC
onready var desc_container = $DESC/ScrollContainer
onready var desc_vb = $DESC/ScrollContainer/VBoxContainer

var selected_mod = null

func update():
	var selected_mod_data = selected_mod["MOD_INFO"]
	var manifest = selected_mod_data.get("manifest",{})
	var description = "HEVLIB_MISSING_DESCRIPTION"
	var author = "HEVLIB_UNKNOWN"
	var credits = []
	if manifest.keys().size() >= 1:
		var data = manifest.get("manifest_data",{})
		if data.keys().size() >= 1:
			var m = data.get("mod_information",{})
			if m.keys().size() >= 1:
				var pd = m.get("description","HEVLIB_MISSING_DESCRIPTION")
				description = pd
				var ad = m.get("author","HEVLIB_UNKNOWN")
				author = ad
				var am = m.get("credits",[])
				credits = am
	nameplate.text = selected_mod_data.get("name","HEVLIB_MISSING_MOD_NAME")
	description_label.text = description
	author_label.text = author
	var txt = ""
	for credit in credits:
		if txt == "":
			txt = credit
		else:
			txt = txt + "\n" + credit
	
	credits_label.text = txt
	if txt == "":
		credits_header.visible = false
		credits_label.visible = false
	else:
		credits_header.visible = true
		credits_label.visible = true
	

func _draw():
	
	desc_container.rect_size = desc_button.rect_size - Vector2(7,12)
#		desc_vb.rect_size.x = desc_container.rect_size.y + 2
	desc_container.rect_position = Vector2(1,1)
	
	update()
	_focus_exited()


onready var scrollcontainer = get_parent().get_node("SPLIT/ModList/ScrollContainer")



func _process(delta):
	if get_focus_owner() == desc_button:
		if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("ui_focus_prev"):
			selected_mod.get_node("ModButton").grab_focus()
			get_viewport().set_input_as_handled()
		if Input.is_action_just_pressed("ui_up"):
			pass
		elif Input.is_action_just_pressed("ui_down"):
			pass
	
	
	
	var focus = get_focus_owner().name
	if focus != "DESC":
		desc_container.scrollWithGamepad = false
		desc_container.scrollWithKeyboard = false
		scrollcontainer.scrollWithGamepad = true
	else:
		desc_container.scrollWithGamepad = true
		desc_container.scrollWithKeyboard = true
		scrollcontainer.scrollWithGamepad = false




func _visibility_changed():
	if scrollcontainer:
		var nodes = scrollcontainer.get_node("VBoxContainer").get_children()
		var node = nodes[0]
		selected_mod = node




func _focus_entered():
	desc_container.scrollWithGamepad = true
	desc_container.scrollWithKeyboard = true
	scrollcontainer.scrollWithGamepad = false
	desc_button.focus_neighbour_right = get_path_to(self)
	desc_button.focus_neighbour_top = get_path_to(self)
	desc_button.focus_neighbour_bottom = get_path_to(self)
	var button = selected_mod.get_node("ModButton")
	var path = desc_button.get_path_to(button)
	desc_button.focus_neighbour_left = path
	desc_button.focus_next = path
	desc_button.focus_previous = path

func _focus_exited():
	desc_container.scrollWithGamepad = false
	desc_container.scrollWithKeyboard = false
	scrollcontainer.scrollWithGamepad = true
