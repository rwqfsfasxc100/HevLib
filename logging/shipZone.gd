extends Label

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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

const pixelToKm = 10000
var map = preload("res://ring/ring-map.png")
var image
var size

var available = false
var accurate_event_counter = false
var visibility = false

var pointers = ModLoader._savedObjects[0]


func hl_shipzone_uv():
	if pointers:
		visibility = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_position_data_debugger")

func _ready():
	yield(get_tree(),"idle_frame")
	image = map.get_data()
	size = image.get_size()
	pointers.ConfigDriver.__establish_connection("hl_shipzone_uv",self)
	
	hl_shipzone_uv()
	accurate_event_counter = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_position_accurate_events")
	if accurate_event_counter:
		Debug.l("HevLib: EventDriver\n\n\n\n###############################################################################################################################################################################\n\nWARNING! HevLib setting 'ring_position_accurate_events' is enabled. Due to the way this setting works, it will decrease performance by a significant enough amount, and will generate thousands of logs per minute.\n\nUSE OF THIS SETTING IS COMPLETELY UNSUPPORTED AND WILL INVALIDATE ALL BUG REPORTS! YOU HAVE BEEN WARNED!\n\n###############################################################################################################################################################################\n\n\n\n")
	
	visible = visibility
	
func _input(event):
	if visibility and Input.is_action_just_pressed("toggle_debug_menus"):
		self.visible = !self.visible

func _process(delta):
#	get_parent().get_parent().rect_size = get_parent().get_parent().get_parent().get_parent().get_parent().rect_size
	var ring = get_node_or_null("/root/Game/TheRing")
	if ring == null:
		available = false
	else:
#		yield(ring,"ready")
		available = true
	if pointers:
		visibility = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_position_data_debugger")
		accurate_event_counter = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_position_accurate_events")
	if visibility:
		visible = true
	else:
		visible = false
	if visibility and available:
		var nodes = get_tree().get_root().get_children()
		var nodeNames = []
		for node in nodes:
			nodeNames.append(node.name)
		var tex = "null"
		var ZonePrefix = "Zone: "
		var ChaosPrefix = "Chaos: "
		var DensityPrefix = "RawDensity: "
		var DensityArrPrefix = "Density: "
		var EventNoPrefix = "Currently Possible Events (predicted): "
		var ActualEventPrefix = "Currently Possible Events (actual): "
		var EventNo = 0
		var chaos = 0
		var density = 0
		var realDensity = []
		var actualEventNo = 0
		var isInGame = false
		if "Game" in nodeNames:
			isInGame = true
		else:
			isInGame = false
		if isInGame:
			ZonePrefix = "Zone: "
			ChaosPrefix = "Chaos: "
			EventNoPrefix = "Currently Possible Events (predicted): "
			ActualEventPrefix = "Currently Possible Events (actual): "
			var ship = CurrentGame.getPlayerShip()
			if ship == null:
				tex = "null"
				chaos = 0
				density = 0
			else:
				tex = ship.zone
				var currentPos = CurrentGame.globalCoords(ship.global_position)
				chaos = getChaosAt(currentPos)
				density = getRawDensityAt(currentPos)
				realDensity = getTargetDensityAt(currentPos)
#				var ring = load("res://story/TheRing.tscn").instance()
				nodes = ring.get_children()
				var chaosNums = []
				var currentEvents = []
				for node in nodes:
					var hasChaos = false
					var properties = node.get_property_list()
					for property in properties:
						if property.get("name") == "chaosLimit":
							chaosNums.append([node.chaosLimit,node.name])
							hasChaos = true
					if not hasChaos:
						chaosNums.append([0.0,node.name])
				for event in chaosNums:
					if event[0] <= chaos:
						EventNo += 1
						currentEvents.append(event[1])
				var actualEventNames = []
				if accurate_event_counter:
					for node in nodes:
						var num = node.canBeAt(currentPos)
						if num:
							actualEventNo += 1
							actualEventNames.append(node.name)
			
		else:
			tex = ""
			chaos = ""
			density = ""
			ZonePrefix = ""
			ChaosPrefix = ""
			DensityPrefix = ""
			DensityArrPrefix = ""
			EventNoPrefix = ""
			EventNo = ""
			ActualEventPrefix = ""
			actualEventNo = ""
			if tex == "" and chaos == "" and density == "" and EventNo == "" and actualEventNo == "" and realDensity.size() == 0:
				visible = false
			else:
				visible = true
		var textToDisplay = ZonePrefix + tex + "\n" + ChaosPrefix + str(chaos) + "\n" + DensityPrefix + str(density) + "\n" + DensityArrPrefix + str(realDensity) + "\n" + EventNoPrefix + str(EventNo)
		if accurate_event_counter:
			textToDisplay = textToDisplay + "\n" + ActualEventPrefix + str(actualEventNo)
		text = textToDisplay

func getChaosAt(pos):
	return getPixelAt(pos).r
func getRawDensityAt(pos):
	return getPixelAt(pos).b
func getTargetDensityAt(pos):
	var pixel = getPixelAt(pos)
	var ships = 1
	var shipAdjust = max(0, ships - 3) * 4
	
	var initialMass = pixel.b * 1024
	var totalMass = initialMass
	var sizeBias = pixel.g
	
	var density = [0, 0, 0, 0, 0]
	var classess = float(density.size() - 1)
	
	for ac in [0, 1, 2, 3, 4]:
		var mc = pow(5 - ac, 2)
		var cfv = float(classess - ac) / classess
		var d = 1 - abs(cfv - sizeBias)
		var pick = totalMass * pow(d, 3)
		density[ac] = clamp(int(pick / mc), 0, maxDensity[ac] + shipAdjust)
		totalMass = max(0, (totalMass - density[ac] * mc))
	
		
	
	return density

const maxDensity = [64, 96, 128, 160, 192]

func getPixelAt(pos):
	var x = int(clamp(floor(pos.x / pixelToKm), 0, size.x - 1))
	var sy = int(size.y)
	var y = ((int(floor(pos.y / pixelToKm)) % sy) + sy) % sy
	var x1 = int(clamp(x + 1, 0, size.x - 1))
	var y1 = (y + 1) % int(size.y)
	
	if x <= 0:
		return Color(0, 0, 0, 0)
	
	var pixel
	image.lock()
	var p00 = image.get_pixel(x, y)
	var p10 = image.get_pixel(x1, y)
	var p11 = image.get_pixel(x1, y1)
	var p01 = image.get_pixel(x, y1)
	image.unlock()
	
	var cx = (pos.x - floor(pos.x / pixelToKm) * pixelToKm) / pixelToKm
	var cy = (pos.y - floor(pos.y / pixelToKm) * pixelToKm) / pixelToKm

	var pu = (p00 * (1 - cx) + p10 * (cx))
	var pd = (p01 * (1 - cx) + p11 * (cx))
	
	pixel = pu * (1 - cy) + pd * (cy)
	return pixel



