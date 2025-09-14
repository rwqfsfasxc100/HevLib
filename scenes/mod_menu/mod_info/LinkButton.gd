extends Button

export var URL = "https://example.com"

export var static_link = true

export var icon_path = NodePath("icon")
export var left_button = NodePath("")
export var left_separator = NodePath("")
export var right_button = NodePath("")
export var right_separator = NodePath("")

export (float) var scale_factor = 1.0

export (String, "github", "discord","nexus","donations","wiki","bug_reports","custom_links")var dynamic_mode = "github" 

onready var ic = get_node(icon_path)

func _ready():
	ic.rect_size = self.rect_size
	ic.expand = true
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var size = ic.rect_size
	var newsize = size * scale_factor
	
	var ox = size.x
	var nx = newsize.x
	var oy = size.y
	var ny = newsize.y
	
	var xpos = ox-nx
	var ypos = oy-ny
	ic.rect_size = Vector2(nx,ny)
	ic.rect_position = Vector2(xpos/2,ypos/2)

func _visibility_changed():
	var tex = StreamTexture.new()
	var fp = ""
	match dynamic_mode:
		"github":
			fp = "res://HevLib/ui/themes/icons/github.stex"
		"discord":
			fp = "res://HevLib/ui/themes/icons/discord.stex"
		"nexus":
			fp = "res://HevLib/ui/themes/icons/nexus.stex"
		"donations":
			fp = "res://HevLib/ui/themes/icons/donations.stex"
		"wiki":
			fp = "res://HevLib/ui/themes/icons/wiki.stex"
		"bug_reports":
			fp = ""
		"custom_links":
			fp = "res://HevLib/ui/themes/icons/custom.stex"
	if fp == "":
		fp = "res://HevLib/ui/themes/icons/file.stex"
	tex.load_path = fp
	ic.texture = tex
	
	$AnimationPlayer.play("draw")
