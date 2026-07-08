extends "res://ships/camera.gd"

onready var EventDriverBaseMouseSpeed:float = mouseSpeed
onready var EventDriverBaseSpeed:float = speed
onready var EventDriverBaseZoomSpeed:float = zoomSpeed
onready var EventDriverBaseZoomAdjustSpeed:float = zoomAdjustSpeed
onready var EventDriverBaseMouseZoomSpeed:float = mouseZoomSpeed

func _ready():
	CurrentGame.connect("eventDriverVisibilityChanged",self,"_eventdriver_visibility_changed")

func _eventdriver_visibility_changed(how):
	mouseSpeed = 0.0 if how else EventDriverBaseMouseSpeed
	speed = 0.0 if how else EventDriverBaseSpeed
	zoomSpeed = 0.0 if how else EventDriverBaseZoomSpeed
	zoomAdjustSpeed = 0.0 if how else EventDriverBaseZoomAdjustSpeed
	mouseZoomSpeed = 0.0 if how else EventDriverBaseMouseZoomSpeed
