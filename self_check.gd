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

extends AcceptDialog

var mod_name : String = "HevLib"
var this_mod_name : String = "Example Mod"
var min_version_major : int = 1 # Setting this to INF will mean no min version is checked
var min_version_minor : int = 0
var min_version_bugfix : int =0

var max_version_major : int = INF # Setting this to INF will mean no max version is checked
var max_version_minor : int = 0
var max_version_bugfix : int = 0

var check_mod_version : bool = false

# Whether to display a confirmation dialogue box to say that the mod is missing
# Will use a default message and mod name if the custom_message_string variable is left blank as ""
# dialogue_box_title sets text to be displayed at the top of the box
var show_dialogue_box : bool = true
var dialogue_box_title : String = "HEVLIB ERROR!"

# If true, the game will close after either the dialogue box is closed, or if show_dialogue_box is false, immediately after the query fails
# If no dialogue box is used, there will be extra logging performed to make sure that the issue is made very clear.
var crash_if_not_found : bool = true

# The file path to the mod main file. The file structure is equivalent to the file structure of the zip file.
var modmain_res_path : String = "res://HevLib/ModMain.gd"

# A custom message that can be used for the dialogue box if enabled.
# Can be both raw text or a translation string, however do make sure that the translation is loaded before this script runs
# This will not use the mod_name string for display, so please make sure to include it in the string
var custom_message_string : String = ""

# open_download_page_on_OK will attempt to open the provided link from download_URL in the browser
# download_URL is intended to be a link to the download page of a mod
# For GitHub links, it's recommended to use the /releases/latest link - e.g. https://github.com/rwqfsfasxc100/HevLib/releases/latest
var open_download_page_on_OK : bool = true
var download_URL : String = "https://github.com/rwqfsfasxc100/HevLib/releases/latest"





# Variable used to decide the query. Can be fetched if set to not close the game
var mod_exists : bool










# Main function body

onready var tree = get_tree().get_root()

func _ready():
	Debug.l("Mod Checker Script: starting check for mod [%s]" % mod_name)
	mod_exists = true
	var dir = Directory.new()
	var does = dir.file_exists(modmain_res_path)
	if does:
		mod_exists = true
	else:
		mod_exists = false
	if mod_exists:
		Debug.l("HevLib Self Verification: %s exists at the proper path!" % mod_name)
	else:
		if show_dialogue_box:
			get_tree().paused = true
			self.connect("confirmed", self, "_confirmed_pressed")
			self.connect("popup_hide", self, "_popup_hide")
			self.connect("tree_exited",self,"_tree_exited")
			
			get_parent().call_deferred("remove_child",self)
			
		else:
			_confirmed_pressed()
		pass

func _confirmed_pressed():
	Debug.l("HevLib Self Verification: mod [%s] exists? [%s]" % [mod_name,mod_exists])
	if open_download_page_on_OK:
		Debug.l("HevLib Self Verification: attempting to open downloads link @ [%s]" % download_URL)
		OS.shell_open(download_URL)
	_popup_hide()

func _popup_hide():
	if not mod_exists and crash_if_not_found:
		Debug.l("HevLib Self Verification: mod %s not found at proper location, exiting game" % mod_name)
		Debug.batchWrite()
		var pid = OS.execute(OS.get_executable_path(), OS.get_cmdline_args(), false)
		OS.kill(OS.get_process_id())

func _tree_exited():
	self.window_title = dialogue_box_title
	self.popup_exclusive = true
	self.rect_min_size = Vector2(300,150)
	
	if custom_message_string == "":
		var text = ""
		var header = "Warning! Missing dependancy for %s\nThe mod %s is not currently installed with the correct version" % [this_mod_name,mod_name]
		var body = "\n\nPlease install a copy of %s that is " % mod_name
		var mx = false
		if min_version_major == int(INF):
			pass
		else:
			var txt = "version %s.%s.%s or newer" % [min_version_major,min_version_minor,min_version_bugfix]
			body = body + txt
			mx = true
			
		
		if max_version_major == int(INF):
			pass
		else:
			if mx:
				body = body + ", and/or is "
			var txt = "version %s.%s.%s or older" % [max_version_major,max_version_minor,max_version_bugfix]
			body = body + txt
		
		if max_version_major == int(INF) and min_version_major == int(INF):
			body = ""
		var bottom = ". \n\nPlease ensure that the mod was downloaded from the correct page, for instance the releases page on GitHub."
		if open_download_page_on_OK:
			bottom = bottom + "\n\nPress OK to open the downloads page."
		self.dialog_text = header + body + bottom
	else:
		self.dialog_text = custom_message_string
	var control = CanvasLayer.new()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var cnum = str(rng.randi())
	rng.randomize()
	var bnum = str(rng.randi())
	control.name = cnum
	self.name = bnum
	control.pause_mode = Node.PAUSE_MODE_PROCESS
	control.layer = 127
	control.add_child(self)
	tree.call_deferred("add_child",control)


func _init():
	self.process_priority = -INF
	self.pause_mode = Node.PAUSE_MODE_PROCESS

func _physics_process(delta):
	if mod_exists == false:
		var screen = OS.get_screen_size()
		rect_position.x = (screen.x - rect_size.x)/2
		rect_position.y = (screen.y - rect_size.y)/2
		self.visible = true
	else:
		self.visible = false
