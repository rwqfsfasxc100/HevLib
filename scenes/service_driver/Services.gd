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

extends "res://enceladus/Services.gd"

onready var service_ui:PackedScene = load("res://HevLib/scenes/service_driver/ServiceUIUniversal.tscn")

var pointers:HevLibPointers
func _ready():
	pointers = ModLoader._savedObjects[0]
	var services_store:Array = pointers.Equipment.services_store
	if services_store:
		var service_item_list:VBoxContainer = $VB/MarginContainer/ScrollContainer/MarginContainer/Items
		var perspective_base:Node2D = $VB/WindowMargin/Window/VP/ViewportContainer/Viewport/EnceladusPerspective
		var flicker_script:Script = load("res://enceladus/Perspective/FlickerLight.gd")
		for item in services_store:
			var itemKeys:Array = item.keys()
			if "name" in itemKeys and item.name:
				var panel:MarginContainer = service_ui.instance()
				var item_name:String = item["name"]
				var layer:String = "Industrial"
				if item.get("layer","industrial")[0].to_lower() == "r":
					layer = "Residential"
				panel.serviceName = item_name
				panel.name = item_name
				panel.connect("view",self,"serviceView")
				panel.allowDebt = item.get("allow_debt",false)
				panel.serviceDescription = item.get("description","")
				panel.serviceOffer = item.get("offer","")
				panel.serviceHours = max(item.get("hours",24),0)
				panel.cooldownHours = max(item.get("cooldown",0),0)
				panel.moraleChange = clamp(item.get("morale_change",0.0),-0.5,0.5)
				panel.moraleStay = clamp(item.get("morale_stability",0.0),-0.5,0.5)
				panel.flatPrice = max(item.get("price",0.0),0.0)
				panel.activeMemberPrice = max(item.get("price_per_active_crew",0.0),0.0)
				panel.totalMemberPrice = max(item.get("price_per_total_crew",0.0),0.0)
				panel.storyLine = item.get("story_flag","")
				panel.storyMin = max(item.get("story_flag_min",-1),-1)
				panel.storyMax = max(item.get("story_flag_max",-1),-1)
				panel.storyHide = item.get("story_flag_hide",false)
				panel.disabledColor = item.get("disabled_color",Color(0.5,0.5,0.5,1.0))
				panel.disabledColor.a = 1.0
				panel.buyOnView = item.get("buy_on_view",false)
				panel.factionBased = item.get("faction_based","")
				panel.fearPrice = max(item.get("fear_price",0.0),0.0)
				panel.hostilityPrice = max(item.get("hostility_price",0.0),0.0)
				panel.insuranceGain = item.get("insurance_gain",0.0)
				var perspective_add_to:Node2D = perspective_base.get_node(layer)
				var cam_data:Dictionary = item.get("camera",{})
				var camera_node:Node2D = Node2D.new()
				camera_node.name = item_name
				var camera_pos:Vector2 = cam_data.get("position",Vector2.ZERO)
				camera_node.position = camera_pos
				var camera_rotation:float = deg2rad(cam_data.get("rotation",0.0))
				camera_node.rotation = camera_rotation
				camera_node.scale = cam_data.get("scale",Vector2.ONE)
				var signs:Array = item.get("signs",[])
				for idx in signs.size():
					var sign_panel:Dictionary = signs[idx]
					var sprite_node:Sprite = Sprite.new()
					sprite_node.name = item_name + "_sprite%d" % idx
					sprite_node.set_script(flicker_script)
					sprite_node.texture = pointers.FileAccess.__load_png(sign_panel.get("sprite",""))
					sprite_node.position = camera_pos + sign_panel.get("position_offset",Vector2.ZERO)
					sprite_node.rotation = camera_rotation + deg2rad(sign_panel.get("rotation_offset",0.0))
					sprite_node.scale = sign_panel.get("scale",Vector2.ONE)
					sprite_node.flicker = sign_panel.get("flicker",0.2)
					sprite_node.flickerBase = sign_panel.get("flicker_base",0.15)
					sprite_node.modulate = sign_panel.get("color",Color.white)
					sprite_node.modulate.a = 1.0
					var light_node:Light2D = Light2D.new()
					light_node.texture = pointers.FileAccess.__load_png(sign_panel.get("light",""))
					light_node.color = sign_panel.get("light_color",Color.white)
					light_node.color.a = 1
					light_node.texture_scale = clamp(sign_panel.get("light_scale",1.0),0.01,50.0)
					light_node.range_height = clamp(sign_panel.get("light_height",100.0),-2048,2048)
					light_node.energy = clamp(sign_panel.get("light_energy",1.0),0.0,16.0)
					light_node.offset = sign_panel.get("light_position_offset",Vector2.ZERO)
					sprite_node.add_child(light_node)
					perspective_add_to.add_child(sprite_node)
				perspective_add_to.add_child(camera_node)
				service_item_list.add_child(panel)
				panel.node = NodePath("../../../../../WindowMargin/Window/VP/ViewportContainer/Viewport/EnceladusPerspective/%s/%s" % [layer,item_name])
				
