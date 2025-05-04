extends Label

const pixelToKm = 10000
var map = preload("res://ring/ring-map.png")
var image
var size

func _ready():
	image = map.get_data()
	size = image.get_size()
	
func _process(delta):
	var visibility = Settings.HevLib["debug"]["ring_position_data_debugger"]
	visible = visibility
	if visibility:
		var nodes = get_tree().get_root().get_children()
		var nodeNames = []
		for node in nodes:
			nodeNames.append(node.name)
		var tex = "null"
		var ZonePrefix = "Zone: "
		var ChaosPrefix = "Chaos: "
		var EventNoPrefix = "Currently Possible Events: "
		var EventNo = 0
		var chaos = 0
		var isInGame = false
		if "Game" in nodeNames:
			isInGame = true
		else:
			isInGame = false
		if isInGame:
			ZonePrefix = "Zone: "
			ChaosPrefix = "Chaos: "
			EventNoPrefix = "Currently Possible Events: "
			var ship = CurrentGame.getPlayerShip()
			if ship == null:
				tex = "null"
				chaos = 0
			else:
				tex = ship.zone
				chaos = getChaosAt(CurrentGame.globalCoords(ship.global_position))
				var ring = load("res://story/TheRing.tscn").instance()
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
				pass
		else:
			tex = ""
			chaos = ""
			ZonePrefix = ""
			ChaosPrefix = ""
			EventNoPrefix = ""
			EventNo = ""
			if tex == "" and chaos == "" and EventNo == "":
				visible = false
			else:
				visible = true
		text = ZonePrefix + tex + "\n" + ChaosPrefix + str(chaos) + "\n" + EventNoPrefix + str(EventNo)

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



