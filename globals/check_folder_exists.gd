extends Node

static func check_folder_exists(folder):
	Debug.l("HevLib: function 'check_folder_exists' instanced for %s" % folder)
	var value = false
	var directory = Directory.new()
	if directory.dir_exists(folder):
		Debug.l("HevLib: Directory %s already exists" % folder)
		value = true
	else:
		var error_code = directory.make_dir_recursive(folder)
		if error_code != OK:
			Debug.l("HevLib: Failed to make folder %s" % folder)
			value = false
		else:
			value = true
			Debug.l("HevLib: Folder created @%s" % folder)
	return value
