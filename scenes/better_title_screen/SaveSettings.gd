extends Popup

var first_time:bool = true

var save_slot_file:String = "user://savegame.dv"

var delete_color:Color = Color(1,1,1,1)

var slot_available:bool = true

var sender

var display_text:String = "TEMPLATE"

var index:int = 0

var registered_text:String = "TEMPLATE"

onready var popup_container = get_parent().get_parent()

func _process(delta):
	var screen:Vector2 = get_viewport().size
	var size:Vector2 = $NoMargins.rect_size
	var pos:Vector2 = Vector2((screen.x - size.x)/2,(screen.y - size.y)/2)
	$NoMargins.rect_position = pos - self.rect_position
	

func cancel():
	hide()

var enable_on_save_buttons:Array = []

var connections:Dictionary = {
	"POPUP_ROOT":[],
	"SAVE_BUTTON":[],
	"ADDITIONAL":[],
	"GENERIC":[]
}

var tt_label = preload("res://menu/sfx/PlaySoundsOnTheseButtons.tscn")

func create():
	var buttons:Array = [{
		"display_name":"CONFIRM_OVERRIDE_GAME",
		"popup_path":null,
		"popup_override":"POPUP_ROOT", # "POPUP_ROOT" for menu root node, "SAVE_BUTTON" for obv save button
		"connect_method":"_on_DELETE_SAVE_pressed",
		"enable_on_save":true,
	}]
	buttons.append_array(ModLoader._savedObjects[0].Equipment.save_button_cache)
	for button in buttons:
		var BUTTON:Button = Button.new()
		var displayname:String = button.get("display_name","MISSING_BUTTON_NAME")
		var tooltip:String = button.get("tooltip","")
		BUTTON.name = displayname
		BUTTON.text = displayname
		if tooltip:
			BUTTON.hint_tooltip = tooltip
			BUTTON.add_child(tt_label.instance())
		var popup_path = button.get("popup_path")
		var method:String = button.get("connect_method","_on_save_option_button_pressed")
		if not popup_path:
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
		if button.get("enable_on_save",false):
			enable_on_save_buttons.append(displayname)
		BUTTON.connect("pressed",self,"cancel")
		get_node("NoMargins/CenterContainer/TabHintContainer/TabsWithGamepadControl/HEVLIB_SAVE_OPTIONS/MarginContainer/MarginContainer/ScrollContainer/VBoxContainer").add_child(BUTTON)

func _about_to_show():
	if first_time:
		create()
		first_time = false
	else:
		reconnect()
	var alphabet = PoolStringArray(["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","10"])
	registered_text = TranslationServer.translate(display_text) + " - " + TranslationServer.translate("HEVLIB_SLOT") + " " + alphabet[float(index)/2]
	$NoMargins/CenterContainer/TabHintContainer/TabsWithGamepadControl.get_child(0).name = registered_text
	var button_container = get_node("NoMargins/CenterContainer/TabHintContainer/TabsWithGamepadControl/" + registered_text + "/MarginContainer/MarginContainer/ScrollContainer/VBoxContainer")
	for button in enable_on_save_buttons:
		var slot = button_container.get_node(button)
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
	
