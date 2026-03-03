extends InputEvent

func is_action_pressed(action,allow_echo = false,exact_match = false):
	var out = Input.is_action_pressed(action,exact_match)
	if out:
		Debug.l("Action %s polled" % [action])
	return out
