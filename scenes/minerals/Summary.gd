extends "res://enceladus/Summary.gd"

func loadOutput(outputData, processed = {}, rem = {}) -> bool:
	var has = .loadOutput(outputData,processed,rem)
	if has:
		var vb = $PC / VBoxContainer
		var margin = vb.get_node("MarginContainer2")
		var new_scroll_bar = VScrollBar.new()
		var hb = HBoxContainer.new()
		hb.add_child(new_scroll_bar)
		var sc = ScrollContainer.new()
		sc.size_flags_horizontal = SIZE_EXPAND_FILL
		sc.set_script(load("res://HevLib/ui/mod_menu/mod_info/ScrollWithKB.gd"))
		sc.scrollWithKeyboard = true
		var current_scroll = sc.get_v_scrollbar()
		current_scroll.rect_scale.x = 0
		hb.add_child(sc)
		var vb2 = VBoxContainer.new()
		vb2.alignment = BoxContainer.ALIGN_END
		hb.add_child(vb2)
		margin.add_child(hb)
		vb.remove_child(gc)
		sc.add_child(gc)
		vb.remove_child(byShipNode)
		vb2.add_child(byShipNode)
		current_scroll.share(new_scroll_bar)
		sizeUp(new_scroll_bar,current_scroll)
	return has

func sizeUp(scroll,current_scroll):
	yield(get_tree(),"idle_frame")
	scroll.visible = current_scroll.visible
	pass
