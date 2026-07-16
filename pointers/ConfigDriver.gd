extends Node

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

const config_name = "Mod_Configurations"

var developer_hint = {
	"__config_parse":[
		"Parses a config file as a dictionary",
		"file -> string containing the file path to the config",
		"File must be formatted to ini standards, e.g. through using the ConfigFile module"
	],
	"__store_config":[
		"Stores a config formatted through a dictionary",
		"id -> string containing the config's identification.",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
		"To associate a config with a mod, set the id to use the mod's name in the mod.manifest file."
	],
	"__get_config":[
		"Retrieves a specific config formatted through a dictionary.",
		"id -> string containing the config's identification.",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
		"To fetch a config associated with a mod, set the id to use the mod's name in the mod.manifest file.",
		"If no respective configuration exists, returns an empty dictionary"
	],
	"__store_value":[
		"Stores an entry into the configuration",
		"id -> string containing the config's identification",
		"section -> string containing the config section",
		"key -> string containing the entry within the section",
		"value -> the desired value of the key. Can be any variable type",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
		"To assign a config entry to be associated with a mod, set the id to use the mod's name in the mod.manifest file.",
	],
	"__get_value":[
		"Fetches an entry from the configuration file",
		"id -> string containing the config's identification",
		"section -> string containing the config section",
		"key -> string containing the entry within the section",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
		"To fetch a config entry associated with a mod, set the id to use the mod's name in the mod.manifest file.",
		"If no respective entry, section, or configuration exists, returns null"
	],
	"__load_configs":[
		"Initializes a configuration file at the given location",
		"Will automatically assign default configurations to any missing entries or sections in the config",
		"Must be run on ready as mod data won't be available before then",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
	],
	"__load_inputs_from_string_array":[
		"Adds inputs for an input action from an array of input keys",
		"key -> string used as the input action to register the input events for",
		"strings -> array of strings for the input events to use. Mouse inputs are prefixed with 'Mouse %s', joy axis inputs are prefixed with 'JoyAxis %s', and joy button inputs are prefixed with 'JoyButton %s'"
	]
}

static func __config_parse(file: String) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ConfigDriver.__config_parse(file)
static func __store_config(id: String, configuration: Dictionary, cfg_filename : String = config_name + ".cfg"):
	preload("res://HevLib/pointers.gd").new().ConfigDriver.__store_config(configuration,id,cfg_filename)
static func __store_value(id: String, section: String, key: String, value, cfg_filename : String = config_name + ".cfg"):
	preload("res://HevLib/pointers.gd").new().ConfigDriver.__store_value(id,section,key,value,cfg_filename)
static func __get_config(id: String, cfg_filename : String = config_name + ".cfg") -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ConfigDriver.__get_config(id,cfg_filename)
static func __get_value(id: String, section: String, key: String, cfg_filename : String = config_name + ".cfg"):
	return preload("res://HevLib/pointers.gd").new().ConfigDriver.__get_value(id,section,key,cfg_filename)
static func __load_configs(cfg_filename : String = config_name + ".cfg"):
	preload("res://HevLib/pointers.gd").new().ConfigDriver.__load_configs(cfg_filename)
static func set_button_focus(button,check_button):
	preload("res://HevLib/pointers.gd").new().ConfigDriver.set_button_focus(button,check_button)

static func __load_inputs_from_string_array(key:String, strings: Array):
	preload("res://HevLib/pointers.gd").new().ConfigDriver.__load_inputs_from_string_array(key,strings)

