extends "res://achievement/Notifications.gd"

onready var viewport_container = $PC / Generic / HBoxContainer / VBoxContainer / Control / ViewportContainer / Viewport / Container
onready var icon = $PC / Generic / HBoxContainer / VBoxContainer / Control / ViewportContainer / Viewport / TextureRect

onready var title = $PC / Generic / Title
onready var desc_a = $PC / Generic / DescriptionA
onready var desc_b = $PC / Generic / DescriptionB
onready var particle_emitter = $PC / Generic / DescriptionA / Control / Particles2D

onready var change_text = $PC / Generic / H / Type
onready var change_from = $PC / Generic / H / C / From
onready var change_to = $PC / Generic / H / C / To

var dir = Directory.new()

func add_vp():
	pass

func clear_vp():
	var nodes = viewport_container.get_children()
	for child in nodes:
		Tool.remove(child)

