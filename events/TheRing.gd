extends "res://TheRing.gd"

var event_names = []
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
#var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
var cache_folder = "user://cache/.HevLib_Cache/"

var current_event_log = {}

var group = {}
var all_oddities = []

func addNearbyOddity(nearby, oddity, pos: Vector2):
	if oddity is Array:
		for o in oddity:
			if not nearby in group:
				group[nearby] = []
			group[nearby].append(o)
			all_oddities.append(o)
	else:
		if not nearby in group:
			group[nearby] = []
		group[nearby].append(oddity)
		all_oddities.append(oddity)
	.addNearbyOddity(nearby, oddity, pos)


func enterNearby(what, id):
	if not what in current_event_log:
		current_event_log.merge({what:{}})
	var ctime = Time.get_datetime_string_from_system(true)
	if not id in current_event_log[what]:
		current_event_log[what].merge({id:{}})
	current_event_log[what][id]["enter_time"] = ctime
	if Time.get_unix_time_from_datetime_string(ctime) > Time.get_unix_time_from_datetime_string(current_event_log[what][id].get("exit_time","2020-01-01T03:45:01")):
		if "exit_time" in current_event_log[what][id].keys():
			current_event_log[what][id].erase("exit_time")
	logEvents()
	
	.enterNearby(what,id)

func exitNearby(what, id):
	var ctime = Time.get_datetime_string_from_system(true)
	current_event_log[what][id]["exit_time"] = ctime
	
	logEvents()
	.exitNearby(what,id)

func getNextOnPlaylist():
	if playlist.size() > 0:
		var value = .getNextOnPlaylist()
		var ev_name = value.name
		
		return value
	else:
		return null

var event_log_file = "user://cache/.HevLib_Cache/Event_Driver/event_log.json"
var active_events_file = "user://cache/.HevLib_Cache/Event_Driver/active_events.txt"
var latest_event_file = "user://cache/.HevLib_Cache/Event_Driver/latest_event.txt"

var file = File.new()
func logEvents():
	file.open(event_log_file,File.WRITE)
	file.store_string(JSON.print(current_event_log,"\t"))
	file.close()
	var current_events = []
	var active_events = ""
	var latest_event = ""
	var latest_event_time = 0
	for eventType in current_event_log:
		var evt = current_event_log[eventType]
		for id in evt:
			var entries = evt[id]
			if not "exit_time" in entries and not eventType in current_events:
				current_events.append(eventType)
				var time = entries.get("enter_time",null)
				if time:
					var actualTime = Time.get_unix_time_from_datetime_string(time)
					if actualTime > latest_event_time:
						latest_event_time = actualTime
						latest_event = eventType
	file.open(latest_event_file,File.READ)
	var currentLatest = file.get_as_text()
	file.close()
	if latest_event != currentLatest:
		file.open(latest_event_file,File.WRITE)
		file.store_string(latest_event)
		file.close()
	for event in current_events:
		active_events = active_events + event + "\n"
	file.open(active_events_file,File.WRITE)
	file.store_string(active_events)
	file.close()

func _ready():
	connect("tree_exiting",self,"wipe_lists")
	file.open(event_log_file,File.WRITE)
	file.store_string("{}")
	file.close()
	file.open(active_events_file,File.WRITE)
	file.store_string("")
	file.close()
	file.open(latest_event_file,File.WRITE)
	file.store_string("")
	file.close()
	current_event_log = {}
	image = map.get_data()
	size = image.get_size()
	
	veinImage = veins.get_data()
	veinSize = veinImage.get_size()
	
#	var de = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events")
#	if de == null:
#		
	var disabled_events = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events")
	if disabled_events == null:
		pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",[])
		disabled_events = []
	var write_events = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","write_events")
	playlist = []
	for kid in get_children():
		var kidName = kid.name
		event_names.append(kidName)
		if kidName in disabled_events:
			Debug.l("%s is in disabled events list, not adding to playlist" % kidName)
		else:
			Debug.l("%s is not in disabled events list, adding to playlist" % kidName)
			if kid.has_method("makeAt") and kid.has_method("canBeAt"):
				playlist.append(kid)
	if write_events:
		var string = ""
		for event in event_names:
			if string == "":
				string = event
			else:
				string = string + "\n" + event
		pointers.FolderAccess.__check_folder_exists(cache_folder)
		var file = File.new()
		file.open(cache_folder + "current_events.txt",File.WRITE)
		file.store_string(string)
		file.close()

func wipe_lists():
	group.clear()
	all_oddities.clear()













#func exitNearby(what, id):
#	if id in potential_events:
#		current_event_log[id].merge({"time_exited":Time.get_datetime_dict_from_system(true)})
#		logEvents()
#	.exitNearby(what, id)
#
#func enterNearby(what, id):
#	if id in potential_events:
#		var log_data = potential_events[id]
#		log_data.merge({"time_added":Time.get_datetime_dict_from_system(true)})
#		current_event_log.merge({id:log_data})
#		logEvents()
#		potential_events.clear()
#	.enterNearby(what, id)
#
#var potential_events = {}
#func getNextOnPlaylist():
#	var o = .getNextOnPlaylist()
#	var log_data = {}
#	var id = hash(o)
#	log_data.merge({"object":o})
#	var n = o.name
#	log_data.merge({"time_added":Time.get_datetime_dict_from_system(true)})
#	potential_events.merge({id:log_data})
##	logEvents()
#	return o
