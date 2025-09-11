extends Popup

var first_time = true

var save_slot_file = "user://savegame.dv"

var delete_color = Color(1,1,1,1)

var slot_available = true

var sender

var display_text = "TEMPLATE"

var index = 0

var registered_text = "TEMPLATE"

onready var popup_container = get_parent().get_parent()

func _process(delta):
	var screen = get_viewport().size
	
	var size = $NoMargins.rect_size
	
	var x = (screen.x - size.x)/2
	var y = (screen.y - size.y)/2
	var pos = Vector2(x,y)
#	breakpoint
	$NoMargins.rect_position = pos - self.rect_position
	

func cancel():
	hide()

var enable_on_save_buttons = []

var connections = {
	"POPUP_ROOT":[],
	"SAVE_BUTTON":[],
	"ADDITIONAL":[],
	"GENERIC":[]
}

var menu_folder = "user://cache/.HevLib_Cache/MenuDriver/"
var save_menu_file = menu_folder + "save_buttons.json"
func create():
	var file = File.new()
	file.open(save_menu_file,File.READ)
	var buttons = JSON.parse(file.get_as_text(true)).result
	file.close()
#	breakpoint
	for button in buttons:
		var BUTTON = Button.new()
		var displayname = button.get("display_name","MISSING_BUTTON_NAME")
		BUTTON.name = displayname
		BUTTON.text = displayname
		var popup_path = button.get("popup_path")
		var method = button.get("connect_method","_on_save_option_button_pressed")
		if popup_path == "" or popup_path == null:
			match button.get("popup_override"):
				"POPUP_ROOT":
					BUTTON.connect("pressed",self,method)
					connections["POPUP_ROOT"].append({BUTTON:["pressed",self,method]})
				"SAVE_BUTTON":
					BUTTON.connect("pressed",sender,method)
					connections["SAVE_BUTTON"].append({BUTTON:["pressed",sender,method]})
		else:
			var popup = load(popup_path).instance()
			if button.get("send_additional_info",false):
				BUTTON.connect("pressed",popup,method,[self.save_slot_file,self.sender])
				connections["ADDITIONAL"].append({BUTTON:["pressed",popup,method]})
			else:
				BUTTON.connect("pressed",popup,method)
				connections["GENERIC"].append({BUTTON:["pressed",popup,method]})
			popup_container.call_deferred("add_child",popup)
		var enable_on_save = button.get("enable_on_save",false)
		if enable_on_save:
			enable_on_save_buttons.append(displayname)
		BUTTON.connect("pressed",self,"cancel")
		get_node("NoMargins/CenterContainer/TabHintContainer/TabsWithGamepadControl/HEVLIB_SAVE_OPTIONS/MarginContainer/MarginContainer/ScrollContainer/VBoxContainer").add_child(BUTTON)
		
		
#	breakpoint

func _about_to_show():
	if first_time:
		create()
		first_time = false
	else:
		reconnect()
	var alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","10"]
	registered_text = TranslationServer.translate(display_text) + " - " + TranslationServer.translate("HEVLIB_SLOT") + " " + alphabet[index/2]
	$NoMargins/CenterContainer/TabHintContainer/TabsWithGamepadControl.get_child(0).name = registered_text
	var button_container = get_node("NoMargins/CenterContainer/TabHintContainer/TabsWithGamepadControl/" + registered_text + "/MarginContainer/MarginContainer/ScrollContainer/VBoxContainer")
	for button in enable_on_save_buttons:
		var slot = button_container.get_node(button)
		
#	var slot = /DELETE_SAVE")
		slot.disabled = !slot_available
		slot.modulate = delete_color

func _on_DELETE_SAVE_pressed():
	sender.newSave()
	cancel()

func _input(event):
	if visible:
		if event.is_action_pressed("ui_cancel"):
			cancel()

func reconnect():
	for button in connections["POPUP_ROOT"]:
		var object = button.keys()[0]
		var data = button.get(object)
		object.disconnect(data[0],data[1],data[2])
		object.connect(data[0],data[1],data[2])
	for button in connections["SAVE_BUTTON"]:
		var object = button.keys()[0]
		var data = button.get(object)
		object.disconnect(data[0],data[1],data[2])
		object.connect(data[0],data[1],data[2])
	for button in connections["ADDITIONAL"]:
		var object = button.keys()[0]
		var data = button.get(object)
		object.disconnect(data[0],data[1],data[2])
		object.connect(data[0],data[1],data[2],[self.save_slot_file,self.sender])
	for button in connections["GENERIC"]:
		var object = button.keys()[0]
		var data = button.get(object)
		object.disconnect(data[0],data[1],data[2])
		object.connect(data[0],data[1],data[2])
	
