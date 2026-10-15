extends "res://enceladus/Services.gd"

onready var service_ui:PackedScene = load("res://HevLib/scenes/service_driver/ServiceUIUniversal.tscn")

var pointers:HevLibPointers
func _ready():
	pointers = ModLoader._savedObjects[0]
	for item in pointers.Equipment.services_store:
		var itemKeys:Array = item.keys()
		if "name" in itemKeys and item.name:
			var panel:MarginContainer = service_ui.instance()
			var item_name:String = item["name"]
			var layer:String = ""
			match item.get("layer","industrial").to_lower():
				"residential":
					layer = "Residential"
				_:
					layer = "Industrial"
			
			var perspective_path : NodePath = NodePath("../../../../../WindowMargin/Window/VP/ViewportContainer/Viewport/EnceladusPerspective/%s/%s" % [layer,item_name])
			
			
			pass
