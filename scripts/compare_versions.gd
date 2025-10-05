extends Node

static func compare_versions(primary_major : int,primary_minor : int,primary_bugfix : int, compare_major : int, compare_minor : int, compare_bugfix : int) -> bool:
	var mod_exists = true
	if primary_major < compare_major:
		mod_exists = false
	elif primary_major == compare_major:
		if primary_minor < compare_minor:
			mod_exists = false
		elif primary_minor == compare_minor:
			if primary_bugfix < compare_bugfix:
				mod_exists = false
	return mod_exists
