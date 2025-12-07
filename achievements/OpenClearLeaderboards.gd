extends Node

const menu = preload("res://HevLib/achievements/ClearLeaderboards.tscn")

func _open():
#	var canvas = get_tree().get_root().get_node_or_null("_HevLib_Gamespace_Canvas/MarginContainer")
#	if canvas:
#		var p = canvas.get_node_or_null("ClearLeaderboards")
#		if not p:
#			var item = menu.instance()
#			canvas.add_child(item)
#			p = item
#
#		p.show_menu()
	pass
	var item = menu.instance()
	add_child(item)
	item.show_menu()
	
	
	
