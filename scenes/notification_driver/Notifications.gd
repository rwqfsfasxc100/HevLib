extends "res://achievement/Notifications.gd"

var dir = Directory.new()

onready var animations = {
	"Show":$Animations/Show,
	"Sound":$Animations/SoundPlay,
	"Title":$Animations/TitlePlay,
	"DescA":$Animations/DescAPlay,
	"DescB":$Animations/DescBPlay,
	"Particles":$Animations/ParticlesPlay,
	"Icon":$Animations/IconPlay,
	"VP":$Animations/VPPlay,
	"Type":$Animations/TypePlay,
	"From":$Animations/FromPlay,
	"To":$Animations/ToPlay,
}

onready var boxes = {
	"VP":$PC/Generic/HBoxContainer/VBoxContainer/Control/ViewportContainer/Viewport,
	"Background":$PC/Generic/HBoxContainer/VBoxContainer/Control/Background,
	"Border":$PC/Generic/HBoxContainer/VBoxContainer/Control/Border,
	"Icon":$PC/Generic/HBoxContainer/VBoxContainer/Control/ViewportContainer/Viewport/TextureRect,
	"Title":$PC/Generic/Title,
	"DescA":$PC/Generic/DescriptionA,
	"DescB":$PC/Generic/DescriptionB,
	"Type":$PC/Generic/H/Type,
	"From":$PC/Generic/H/C/From,
	"To":$PC/Generic/H/C/To,
}

func _ready():
	CurrentGame.connect("generic_notification",self,"_notification_start")
	tween = Tween.new()
	add_child(tween)
	

var vp_objects = []
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
var tween
func _notification_start(data):
	var title = data.get("title",{}).get("text","NOTIFICATION_TITLE_PLACEHOLDER")
	var desc_a = data.get("body",{}).get("text","NOTIFICATION_NAME_PLACEHOLDER")
	var desc_b = data.get("description",{}).get("text","")
	var particles = data.get("particles",{}).get("show",false)
	var background = data.get("scene",{}).get("background",{}).get("path","res://HevLib/ui/panels/none.stex")
	var border = data.get("scene",{}).get("border",{}).get("path","res://HevLib/achievements/achievement_border.stex")
	var scene = data.get("scene",{}).get("path","")
	var pos = data.get("scene",{}).get("position",Vector2(0,0))
	var scale = data.get("scene",{}).get("scale",Vector2(1,1))
	var rotation = data.get("scene",{}).get("rotation",0)
	var rot_speed = data.get("scene",{}).get("rotation_speed",0)
	var icon = data.get("icon",{}).get("path","")
	var type = data.get("transition",{}).get("label","")
	var from = data.get("transition",{}).get("old","")
	var to = data.get("transition",{}).get("new","")
	
	
	if animation.is_playing():
		yield(animation, "animation_finished")
	animation.play("generic")
	clear_vp()
	animations.Show.play("show")
	animations.Sound.play("Sound")
	boxes.Title.text = title
	boxes.DescA.text = desc_a
	animations.Title.play("Title")
	animations.DescA.play("DescA")
	if desc_b != "":
		boxes.DescB.text = desc_b
		animations.DescB.play("DescB")
	if type != "":
		boxes.Type.text = type
		animations.Type.play("Type")
	if from != "":
		boxes.From.text = from
		animations.From.play("From")
	if to != "":
		boxes.To.text = to
		animations.To.play("To")
	if icon != "" and icon.ends_with(".stex"):
		var tex = StreamTexture.new()
		tex.load_path = icon
		boxes.Icon.texture = tex
		animations.Icon.play("IconPlay")
	if scene != "" and scene.ends_with(".tscn"):
		var i = load(scene).instance()
		pointers.NodeAccess.__remove_scripts(i)
		
		boxes.VP.get_node("Container/Rotation_offset").add_child(i)
		vp_objects.append(i)
		tween.interpolate_property(boxes.VP.get_node("Container"),"rotation",0,(4 * deg2rad(rot_speed)),4,Tween.TRANS_LINEAR)
		tween.start()
#		if "shipName" in i:
#			i.setReactorState(false)
#			i.preheat = false
#			i.cutscene = true
#		if i is RigidBody2D:
#			i.can_sleep = true
#			i.linear_damp = 1024
#			i.angular_damp = 1024
#		if "dummy" in i:
#			i.dummy = true
		boxes.VP.get_node("Container/Rotation_offset").position = pos
		boxes.VP.get_node("Container/Rotation_offset").rotation = deg2rad(rotation)
		boxes.VP.get_node("Camera2D").zoom.x = 1/scale.x
		boxes.VP.get_node("Camera2D").zoom.y = 1/scale.y
		i.call_deferred("set_physics_process",false)
		i.call_deferred("set_physics_process_internal",false)
		i.call_deferred("set_process",false)
		i.call_deferred("set_process_internal",false)
		if border != "" and border.ends_with(".stex"):
			var tex = StreamTexture.new()
			tex.load_path = border
			boxes.Border.texture = tex
		if background != "" and background.ends_with(".stex"):
			var tex = StreamTexture.new()
			tex.load_path = background
			boxes.Background.texture = tex
		animations.VP.play("VP")
	
	

#const NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")

func add_vp():
	pass

func clear_vp():
	
	for child in vp_objects:
		Tool.remove(child)

