extends VBoxContainer

export (float) var MANIFEST_VERSION = 2.2

func EXPORT():
	var STATE = {"manifest_definitions":{"manifest_version":MANIFEST_VERSION}}
	for i in get_children():
		if i.has_method("export_as"):
			var data = i.export_as()
			var d0 = data[0]
			var d1 = data[1]
			if not d0 in STATE:
				STATE[d0] = {}
			STATE[d0].merge(d1)
	return STATE

func IMPORT(STATE):
	for i in get_children():
		if i.has_method("import_as"):
			i.import_as(STATE)
	update()
