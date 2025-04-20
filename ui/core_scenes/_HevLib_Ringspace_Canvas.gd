extends CanvasLayer

var currentNodeRes = Vector2(1280,720)

func _process(delta):
	if not get_parent().get_node_or_null("Game") == null:
		currentNodeRes = get_parent().get_node("Game/TitleAnimPlayer/SubtitleLayer/IntroContainer").rect_size
	$MarginContainer.rect_size = currentNodeRes
