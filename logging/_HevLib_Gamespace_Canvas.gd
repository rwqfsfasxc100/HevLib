extends CanvasLayer

var currentNodeRes = Vector2(1280,720)
var can_work = false

func _ready():
	can_work = true

func _process(delta):
	if can_work:
#		var siblingCount = get_parent().get_child_count()
#		get_parent().move_child(self, siblingCount)
		if not get_parent().get_node_or_null("TitleScreen") == null:
			currentNodeRes = get_parent().get_node("TitleScreen/MenuLayer/TitleMenu").rect_size
		if not get_parent().get_node_or_null("Enceladus") == null:
			currentNodeRes = get_parent().get_node("Enceladus/EnceladusMenu/MenuContainer").rect_size
		if not get_parent().get_node_or_null("Game") == null:
			currentNodeRes = get_parent().get_node("Game/TitleAnimPlayer/SubtitleLayer/IntroContainer").rect_size
		$MarginContainer.rect_size = currentNodeRes
#		var siblingCount = get_parent().get_child_count()
#		get_parent().move_child(self, siblingCount)
	
	
	
