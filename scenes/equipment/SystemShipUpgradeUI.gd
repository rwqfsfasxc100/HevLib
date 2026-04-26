extends "res://enceladus/SystemShipUpgradeUI.gd"

export (String) var config_id = ""
export (String) var config_section = ""
export (String) var config_setting = ""
export (bool) var invert_config = false
var pointers
var cv = null
func visibilityChanged():
	.visibilityChanged()
	if is_visible_in_tree():
		if not pointers:
			pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
		if pointers:
			cv = pointers.ConfigDriver.__get_value(config_id,config_section,config_setting)

func isAvailable():
	var how = .isAvailable()
	if how:
		if config_id and config_section and config_setting:
			if cv != null:
				if invert_config:
					if cv:
						visible = false
				else:
					if !cv:
						visible = false
	return how
