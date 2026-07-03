extends VBoxContainer

var pointers

func _tree_entered():
	var sTime = OS.get_system_time_msecs()
	pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	if pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","do_sort_equipment_by_price"):
		for slot in display_slots():
			sort_slot(slot)
	if pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","do_sort_slots_by_type"):
		reorganize_slots()
	var finish_time = OS.get_system_time_msecs()
	var total_time = str(float(finish_time - sTime)/1000)
	var spl = total_time.split(".")
	var secs = str(spl[0])
	var msecs = str(spl[1])
	while msecs.begins_with("0"):
		msecs = msecs.substr(1)
	pointers.l("Finished adding equipment. Process took a total time of %s seconds, %s milliseconds" % [secs,msecs])

func sort_slot(slot):
	pointers.l("Sorting equipment for slot %s" % slot.name)
	var items = slot.get_node("VBoxContainer").get_children()
	var nodePositions = []
	for item in items:
		nodePositions.append([item, item.get_index()])
	var noFail = false
	var maxIndex = items.size()
	while noFail == false:
		var doesFailThisLoop = false
		for item in slot.get_child(0).get_children():
			if item.get_index() < 2:
				pass
			else:
				var A = item
				var B = A.get_parent().get_child(A.get_index() - 1)
				if A.price < B.price:
					doesFailThisLoop = true
					A.get_parent().move_child(A, B.get_index())
		if doesFailThisLoop:
			noFail = false
		else:
			noFail = true

func display_slots() -> Array:
	var children = self.get_children()
	var list = []
	for child in children:
		if child.get_parent() == self:
			list.append(child)
	return list

var slot_order_cache_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/slot_order.json"
var slot_order_relative_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/slot_order_relative.json"
func reorganize_slots():
	var slot_names = []
	var slot_types = {}
	var slot_types_i = {}
	var f = File.new()
	f.open(slot_order_cache_file,File.READ)
	var order = JSON.parse(f.get_as_text(true)).result
	f.close()
	f.open(slot_order_relative_file,File.READ)
	var order2 = JSON.parse(f.get_as_text(true)).result
	f.close()
	var slotnames = []
	for slot in get_children():
		slotnames.append(slot.name)
		var children = slot.get_node("VBoxContainer").get_children()
		if children.size() <= 1:
			continue
		slot_names.append(slot.name)
		var sys_slot = slot.slot
		var index = 1
		if sys_slot == "":
			while not sys_slot:
				sys_slot = children[index].slot
				index += 1
		slot_types.merge({slot.name:sys_slot})
		slot_types_i.merge({sys_slot:slot.name})
	var sys_dict = {}
	for slot in slot_types:
		var sys = slot_types[slot].split(".")
		var sys_main = sys[0]
		if sys_main in sys_dict.keys():
			sys_dict[sys_main].append(slot)
		else:
			sys_dict[sys_main] = [slot]
	var index = 0
	for sys in sys_dict:
		var arr = sys_dict.get(sys)
		var ordering = []
		for item in order:
			if item in arr:
				ordering.append(item)
		for item in arr:
			if item in slotnames:
				move_child(get_node(item),index)
				index += 1
		for item in ordering:
			move_child(get_node(item),index - 1)
	for slot in order2:
		if slot in slot_types:
			var data = order2[slot]
			var against = data.get("relative_to",null)
			if against:
				var nd = get_node(slot)
				var name_or_config = data.get("use_node_name",true)
				var targetNode = null
				if name_or_config:
					targetNode = get_node_or_null(against)
				else:
					targetNode = get_node_or_null(slot_types_i.get(against,""))
				if targetNode:
					var targetPos = targetNode.get_position_in_parent()
					var entire_group = data.get("entire_group",true)
					if data.get("order_below",true):
						if entire_group:
							var cf = against
							if name_or_config:
								cf = slot_types.get(against,null)
							if cf:
								targetPos += sys_dict.get(cf.split(".")[0]).size()
							else:
								targetPos += 1
						else:
							targetPos += 1
					else:
						if entire_group:
							var cf = against
							var cn = against
							if name_or_config:
								cf = slot_types.get(against,null)
							else:
								cn = slot_types_i.get(against,null)
							if cf and cn:
								var av = sys_dict.get(cf.split(".")[0])[0]
								targetPos = get_node(av).get_position_in_parent()
					move_child(nd,targetPos)
