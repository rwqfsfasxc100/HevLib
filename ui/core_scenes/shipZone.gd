extends Label

const pixelToKm = 10000
var map = preload("res://ring/ring-map.png")
var image
var size

var available = false
var accurate_event_counter = false
var visibility = false

func _ready():
	image = map.get_data()
	size = image.get_size()
	accurate_event_counter = Settings.HevLib["debug"]["ring_position_accurate_events"]
	if accurate_event_counter:
		Debug.l("HevLib: EventDriver\n\n\n\n###############################################################################################################################################################################\n\nWARNING! HevLib setting 'ring_position_accurate_events' is enabled. Due to the way this setting works, it will decrease performance by a significant enough amount, and will generate thousands of logs per minute.\n\nUSE OF THIS SETTING IS COMPLETELY UNSUPPORTED AND WILL INVALIDATE ALL BUG REPORTS! YOU HAVE BEEN WARNED!\n\n###############################################################################################################################################################################\n\n\n\n")
	visibility = Settings.HevLib["debug"]["ring_position_data_debugger"]
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
	visibility = Settings.HevLib["debug"]["ring_position_data_debugger"]
	
	
	if visibility and available:
		var nodes = get_tree().get_root().get_children()
		var nodeNames = []
		for node in nodes:
			nodeNames.append(node.name)
		var tex = "null"
		var ZonePrefix = "Zone: "
		var ChaosPrefix = "Chaos: "
		var EventNoPrefix = "Currently Possible Events (predicted): "
		var ActualEventPrefix = "Currently Possible Events (actual): "
		var EventNo = 0
		var chaos = 0
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
			else:
				tex = ship.zone
				var currentPos = CurrentGame.globalCoords(ship.global_position)
				chaos = getChaosAt(currentPos)
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
			ZonePrefix = ""
			ChaosPrefix = ""
			EventNoPrefix = ""
			EventNo = ""
			ActualEventPrefix = ""
			actualEventNo = ""
			if tex == "" and chaos == "" and EventNo == "" and actualEventNo == "":
				visible = false
			else:
				visible = true
		var textToDisplay = ZonePrefix + tex + "\n" + ChaosPrefix + str(chaos) + "\n" + EventNoPrefix + str(EventNo)
		if accurate_event_counter:
			textToDisplay = textToDisplay + "\n" + ActualEventPrefix + str(actualEventNo)
		text = textToDisplay

func getChaosAt(pos):
	return getPixelAt(pos).r

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



