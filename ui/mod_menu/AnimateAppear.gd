extends AnimationPlayer

export (String, "bloom","flat","empty") var mode = "bloom"
export (float,0.25,4.0,0.05) var speed = 1.0
onready var parent = get_parent()


func _ready():
	
	if "self_modulate" in parent:
		parent.connect("visibility_changed",self,"play_anim")


func play_anim():
	if parent.visible:
		playback_speed = speed
		match mode:
			"bloom":
				play("show")
			"flat":
				play("show_flat")
	else:
		stop(true)
