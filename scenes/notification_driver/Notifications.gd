extends "res://achievement/Notifications.gd"

onready var viewport_container = $PC / Generic / HBoxContainer / VBoxContainer / Control / ViewportContainer / Viewport / Container
onready var icon = $PC / Generic / HBoxContainer / VBoxContainer / Control / ViewportContainer / Viewport / TextureRect

onready var title = $PC / Generic / Title
onready var desc_a = $PC / Generic / DescriptionA
onready var desc_b = $PC / Generic / DescriptionB

onready var change_text = $PC / Generic / H / Type
onready var change_from = $PC / Generic / H / C / From
onready var change_to = $PC / Generic / H / C / To

var dir = Directory.new()

func _generic(title_string : String, description : String, secondary_desc : String = "", change : String = "", change_first : String = "", change_second : String = "", icon_path : String = "", icon_scene_positioning : Dictionary = {"position":Vector2(100,100),"rotation":90,"scale":Vector2(2,2)}):
	if animation.is_playing():
		yield(animation, "animation_finished")
	title.text = title_string
	desc_a.text = description
	if secondary_desc != "":
		desc_b.visible = true
		desc_b.text = secondary_desc
	else:
		desc_b.visible = false
	if change != "":
		change_text.visible = true
		change_text.text = change
	else:
		change_text.visible = false
	if change_first != "":
		change_from.visible = true
		change_from.text = change_first
	else:
		change_from.visible = false
	if change_second != "":
		change_to.visible = true
		change_to.text = change_second
	else:
		change_to.visible = false
	if icon_path != "" and dir.file_exists(icon_path):
		if icon_path.ends_with(".stex"):
			icon.visible = true
			var tex = StreamTexture.new()
			tex.load_path = icon_path
			icon.texture = tex
		elif icon_path.ends_with(".tscn"):
			viewport_container.visible = true
			
		
		
	
	animation.play("gone")

func clear_vp():
	var nodes = viewport_container.get_children()
	for child in nodes:
		Tool.remove(child)

