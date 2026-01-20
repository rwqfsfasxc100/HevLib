extends Popup

const FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")

var profiles = []
var display = []

var current = -1

var new = -1

var forceReboot = false

onready var profile_selections = $PanelContainer/VBoxContainer/Main/VBoxContainer/ProfileSelections
var c = ConfigFile.new()
var dir = Directory.new()

var profiles_dir = "user://cfg/.profiles/"
var profiles_setter = ".profiles.ini"

func _about_to_show():
	lastFocus = get_focus_owner()
	refresh_list()

func refresh_list():
	profiles = []
	display = []
	profile_selections.clear()
	profiles = FolderAccess.__fetch_folder_files(profiles_dir)
	if ".profiles.ini" in profiles:
		profiles.erase(".profiles.ini")
	for i in profiles:
		var entry = i.split("." + i.split(".")[i.split(".").size() - 1])[0]
		display.append(entry)
	for i in display:
		profile_selections.add_item(i)
	c.load(profiles_dir + profiles_setter)
	current = display.find(c.get_value("profiles","selected","Default"))
	new = current
	c.clear()
	
	$PanelContainer/VBoxContainer/Modify/Delete/Button.disabled = (display.size() <= 1)
	profile_selections.selected = current

func add_profile(txt):
	c.set_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name",txt)
	c.save(profiles_dir + txt + ".cfg")
	c.clear()
	refresh_list()
	new = display.find(txt)
	profile_selections.selected = new

func rename_profile(txt):
	var old = display[profile_selections.selected]
	var oldcfg = profiles_dir + old + ".cfg"
	c.load(oldcfg)
	c.set_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name",txt)
	c.save(profiles_dir + txt + ".cfg")
	c.clear()
	dir.remove(oldcfg)
	refresh_list()
	c.load(profiles_dir + profiles_setter)
	new = display.find(txt)
	c.clear()
	profile_selections.selected = new

func delete_profile():
	var oldpos = profile_selections.selected
	if oldpos == 0:
		forceReboot = true
	var old = display[profile_selections.selected]
	var oldcfg = profiles_dir + old + ".cfg"
	dir.remove(oldcfg)
	var disp2 = display.duplicate(true)
	disp2.erase(old)
	var nv = disp2[0]
	refresh_list()
	
	c.set_value("profiles","selected",nv)
	c.save(profiles_dir + profiles_setter)
	c.clear()
	
	pass

func show_menu():
	popup_centered()

func cancel():
	$AnimateAppear.play("hider")
func hider():
	hide()
	refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

func save_selection(index):
	var i = profiles[index]
	var conf = i.split("." + i.split(".")[i.split(".").size() - 1])[0]
	
	c.set_value("profiles","selected",conf)
	c.save(profiles_dir + profiles_setter)
	c.clear()
	Settings.restartGame()

func profile_select(index):
	new = index


func save_profile_selection():
	if (new != current) or forceReboot:
		save_selection(new)
	else:
		hide()


