extends Button

var file = File.new()
var update_store = "user://cache/.HevLib_Cache/needs_updates.json"
func _ready():
	file.open(update_store,File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	if data.keys().size() == 0:
		visible = false
	else:
		visible = true
		
		breakpoint
