extends PanelContainer

onready var button = $VBoxContainer/Button
onready var label = $VBoxContainer/Label
onready var confirm = $ConfirmationDialog

onready var pointers = ModLoader._savedObjects[0]

func _ready():
	var property:String = str(pointers.ManifestV2.__get_mod_data(true).hash())
	label.text = property
	button.connect("pressed",self,"popup_confirmation")
	confirm.connect("confirmed",self,"send_msg")
	get_parent().visible = true
func popup_confirmation():
	confirm.popup_centered()
func send_msg():
	var api_url = "https://publicactiontrigger.azurewebsites.net/api/dispatches/rwqfsfasxc100/dv_update_database"
	var payload = {"event_type":"fetch_data","client_payload":{"data":""}}
	$HTTPRequest.request(api_url,[],true,HTTPClient.METHOD_POST,JSON.print(payload))
