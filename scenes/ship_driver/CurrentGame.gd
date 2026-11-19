# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
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

extends "res://CurrentGame.gd"

onready var pointersShipDriver:HevLibPointers = ModLoader._savedObjects[0]
var modded_ship_list:Array = Array()

var added_modded_ships:bool = false

var hl_shipdriverinitializer_uinit : bool = false
func _ready():
	if hl_shipdriverinitializer_uinit:
		pointersShipDriver.main_modmain.log_double_load_error(get_script().resource_path)
	hl_shipdriverinitializer_uinit = true
	pointersShipDriver.ConfigDriver.__establish_connection("hl_shipdriver_init_ships_to_dealer",self)
	hl_shipdriver_init_ships_to_dealer()
	initialize_scrapwright()

func createShipInstanceWithCache(nv, age, sd, stock = false):
	if nv.begins_with("HevLibShipyardEntry") and age == 0:
		var entry:Dictionary = modded_ship_list[sd % modded_ship_list.size()]
		nv = entry.name
		age = entry.age
	return .createShipInstanceWithCache(nv, age, sd, stock)

var previous_count:int = 0

func hl_shipdriver_init_ships_to_dealer():
	modded_ship_list = Array()
	var add_ship_store:Array = pointersShipDriver.Equipment.add_ships_store
	for fd in add_ship_store:
		var fdk:Array = fd.keys()
		if pointersShipDriver.ConfigDriver.__validate_dictionary(fd,true,true,true,"settings_config") and "name" in fdk and fd.name and "dealer" in fdk:
			var shipName:String = fd["name"]
			if "path" in fdk and fd.path:
				if pointersShipDriver.FileAccess.__file_exists(fd.path):
					for i in max(0,fd["dealer"].get("weight",1)):
						modded_ship_list.append({"name":shipName,"age":24 * 3600 * 365 * fd["dealer"].get("age",200)})
				else:
					pointersShipDriver.l("ERROR: Failed to add modded ship [%s] to the dealership pool due to it's ship scene not being a valid filepath." % shipName,"ShipDriver")
			else:
				pointersShipDriver.l("Skipping addition of modded ship instance [%s] to the dealership pool due to it not adding a ship scene." % shipName,"ShipDriver")
	var rng:int = pointersShipDriver.ConfigDriver.__get_config("HevLib").get("HEVLIB_CONFIG_SECTION_DRIVERS",Dictionary()).get("max_modded_dealership_pools",7)
	if previous_count == rng:
		return
	previous_count = rng
	if added_modded_ships:
		hl_shipdriver_clear_modded_ships()
	for i in clamp(modded_ship_list.size(),0,rng):
		usedShipsPool.append({"name":"HevLibShipyardEntry|%s" % i,"age":0})
	added_modded_ships = true

func hl_shipdriver_clear_modded_ships():
	var list:Array = Array()
	for r in usedShipsPool.size():
		var i:Dictionary = usedShipsPool[r]
		if i["name"].begins_with("HevLibShipyardEntry|"):
			list.push_front(r)
	for i in list:
		usedShipsPool.remove(i)

const scrap_header = "[gd_scene load_steps=3 format=2]\n\n[ext_resource path=\"res://comms/ConversationPlayer.gd\" type=\"Script\" id=1]\n[ext_resource path=\"res://comms/conversation/SalvageBanter.tscn\" type=\"PackedScene\" id=2]\n\n[node name=\"SalvageBanter\" instance=ExtResource( 2 )]\n"
const scrap_entry = "\n[node name=\"%s\" type=\"Node\" parent=\"DIALOG_SALVAGE_START_1\"]\nscript = ExtResource( 1 )\nweight = 0.1\nfakeTransponder = \"SE1-SRO\"\nnoReplyTimeout = 20.0\nimportChildren = NodePath(\"..\")\nstoryFlag = \"count\"\nstoryFlagMax = 2\nstoryFlagIncrement = 1\ntemporaryStory = true\npoiExposeName = \"%s\"\npoiExposeParam = \"{random/ship/1/shipname}\"\npoiExposeUnique = false\npoiExposeEvent = \"%s\"\npoiDistanceKm = 100.0\npoiDistanceRandom = 1500.0\npoiTrackable = false\npoiMustBeValid = true\npoiMustBeAlone = true\npoiValidationTries = 3\ntrueRandom = true\nonlyOnce = true\n"

func initialize_scrapwright():
	var scrap_concat:String = ""
	for data in pointersShipDriver.Equipment.add_ships_store:
		var dkeys:Array = data.keys()
		if pointersShipDriver.ConfigDriver.__validate_dictionary(data,false) and "name" in dkeys and data.name and "salvage_broadcast" in dkeys:
			var shipName:String = data["name"]
			if "path" in dkeys and data.path:
				if pointersShipDriver.FileAccess.__file_exists(data.path):
					var dname:String = data.get("specific_derelict_name","ModdedDerelict_" + shipName)
					var salv = data["salvage_broadcast"]
					if salv is Array or salv is PoolStringArray:
						for i in salv:
							if i:
								scrap_concat += scrap_entry % [i,"POI_SALVAGE",dname]
					elif salv is Dictionary:
						for i in salv.keys():
							if i:
								scrap_concat += scrap_entry % [i,salv[i].get("poi_name","POI_SALVAGE"),dname]
				else:
					pointersShipDriver.l("WARNING: Failed to add modded ship [%s] to the SRO broadcast pool due to it's ship scene not being a valid filepath." % shipName,"ShipDriver")
			else:
				pointersShipDriver.l("Skipping addition of modded ship instance [%s] to the SRO broadcast pool due to it not adding a ship scene." % shipName,"ShipDriver")
	if scrap_concat:
		pointersShipDriver.DataFormat.__replace_scene(scrap_header + scrap_concat,"res://comms/conversation/SalvageBanter.tscn")
