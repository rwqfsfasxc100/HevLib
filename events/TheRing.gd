extends "res://TheRing.gd"

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

var pointers

var cache_folder : String = "user://cache/.HevLib_Cache/"

var current_event_log : Dictionary = {}

var group : Dictionary = {}
var all_oddities : Array = []

var mod_requested_events : Array = []
var mod_request_log : Dictionary = {}

var base_playlist : Array = []
var disabled_events : Array = []
onready var dummy_event = load("res://HevLib/events/event_selector/DummyEvent.gd").new()
func hl_ring_UV():
	if pointers:
		base_playlist = []
		disabled_events.clear()
		disabled_events = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events")
		if not disabled_events:
			pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",[])
			disabled_events = []
		
		var write_events:bool = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","write_events")
		for i in get_children():
			base_playlist.append(i.name)
		if write_events:
			var string : Dictionary = {}
			for event in base_playlist:
				string[event] = not event in disabled_events
			pointers.FolderAccess.__check_folder_exists(cache_folder)
			file.open(cache_folder + "current_events.txt",File.WRITE)
			file.store_string(JSON.print(string,"\t"))
			file.close()
		
		playlist = []
		if disabled_events.size() >= base_playlist.size():
			playlist.append(dummy_event)
		else:
			for event in base_playlist:
				if not event in disabled_events:
					playlist.append(get_node(event))

func forcedOddityConfirmed(which):
	unspawnedOddities.erase(which)
	unspawnedOdditiesLocation.erase(which)
	Debug.l("forced oddity %s confirmed (somehow)" % [which])

func request_event(oddity,event):
	mod_requested_events.append(oddity)
	Debug.l("HevLib Event Driver: event %s requested" % event)
	if oddity is Array:
		for o in oddity:
			if not event in group:
				group[event] = []
			group[event].append(o)
			all_oddities.append(o)
	else:
		if not event in group:
			group[event] = []
		group[event].append(oddity)
		all_oddities.append(oddity)
	var id:int = hash(oddity)
	if not event in mod_request_log:
		mod_request_log.merge({event:{}})
	var ctime : String = Time.get_datetime_string_from_system(true)
	if not id in mod_request_log[event]:
		mod_request_log[event].merge({id:{}})
	mod_request_log[event][id]["enter_time"] = ctime
	file.open(mod_request_file,File.WRITE)
	file.store_string(JSON.print(mod_request_log,"\t"))
	file.close()

func getOddityAt(pos: Vector2):
	if mod_requested_events:
		return mod_requested_events.pop_front()
	return .getOddityAt(pos)

func addNearbyOddity(nearby, oddity, pos: Vector2):
	oddity_spawning(nearby, oddity)
	.addNearbyOddity(nearby, oddity, pos)

func oddity_spawning(nearby, oddity):
	if oddity is Array:
		for o in oddity:
			if not nearby in group:
				group[nearby] = []
			if not oddity in group[nearby]:
				group[nearby].append(oddity)
			if not oddity in all_oddities:
				all_oddities.append(oddity)
	else:
		if not nearby in group:
			group[nearby] = []
		if not oddity in group[nearby]:
			group[nearby].append(oddity)
		if not oddity in all_oddities:
			all_oddities.append(oddity)

func enterNearby(what, id):
	if not what in current_event_log:
		current_event_log.merge({what:{}})
	var ctime : String = Time.get_datetime_string_from_system(true)
	if not id in current_event_log[what]:
		current_event_log[what].merge({id:{}})
	current_event_log[what][id]["enter_time"] = ctime
	if Time.get_unix_time_from_datetime_string(ctime) > Time.get_unix_time_from_datetime_string(current_event_log[what][id].get("exit_time","2020-01-01T03:45:01")):
		if "exit_time" in current_event_log[what][id].keys():
			current_event_log[what][id].erase("exit_time")
	logEvents()
	
	.enterNearby(what,id)

func exitNearby(what, id):
	var ctime : String = Time.get_datetime_string_from_system(true)
	current_event_log[what][id]["exit_time"] = ctime
	
	logEvents()
	.exitNearby(what,id)

var isDummy = false
func getNextOnPlaylist():
	if playlist:
		var value = .getNextOnPlaylist()
		return value
	else:
		return dummy_event

var event_log_file : String = "user://cache/.HevLib_Cache/Event_Driver/event_log.json"
var active_events_file : String = "user://cache/.HevLib_Cache/Event_Driver/active_events.txt"
var latest_event_file : String = "user://cache/.HevLib_Cache/Event_Driver/latest_event.txt"
var mod_request_file : String = "user://cache/.HevLib_Cache/Event_Driver/requested_events_from_mods.txt"
func _exit_tree():
	if current_event_log:
		Debug.l("Ring exiting tree, active events log:\n\n%s\n" % [JSON.print(current_event_log,"\t")])
	
var file:File = File.new()
func logEvents():
	file.open(event_log_file,File.WRITE)
	file.store_string(JSON.print(current_event_log,"\t"))
	file.close()
	var current_events : Array = []
	var active_events : String = ""
	var latest_event : String = ""
	var latest_event_time:int = 0
	for eventType in current_event_log:
		var evt : Dictionary = current_event_log[eventType]
		for id in evt:
			var entries = evt[id]
			if not "exit_time" in entries and not eventType in current_events:
				current_events.append(eventType)
				var time : String = entries.get("enter_time","")
				if time:
					var actualTime:int = Time.get_unix_time_from_datetime_string(time)
					if actualTime > latest_event_time:
						latest_event_time = actualTime
						latest_event = eventType
	file.open(latest_event_file,File.READ)
	var currentLatest : String = file.get_as_text()
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
	pointers = ModLoader._savedObjects[0]
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
	file.open(mod_request_file,File.WRITE)
	file.store_string("")
	file.close()
	current_event_log = {}
	image = map.get_data()
	size = image.get_size()
	
	veinImage = veins.get_data()
	veinSize = veinImage.get_size()
	
	pointers.ConfigDriver.__establish_connection("hl_ring_UV",self)
	if not playlist:
		yield(get_tree(),"idle_frame")
	hl_ring_UV()

func wipe_lists():
	group.clear()
	all_oddities.clear()
