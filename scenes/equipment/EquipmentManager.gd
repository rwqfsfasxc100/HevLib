extends VBoxContainer

func _tree_entered():
	add_slots()
	add_equipment()

func add_slots():
	
	
	
	pass


func add_equipment():
	var Equipment = load("res://HevLib/pointers/Equipment.gd")
	var slot = Equipment.__make_slot("slot.new.type","NewSlot", "SLOT_NEW")
	add_child(slot)
