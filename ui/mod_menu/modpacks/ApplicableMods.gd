extends VBoxContainer


onready var applicable_list = $ScrollContainer/VBoxContainer
onready var applicable_label = preload("res://HevLib/ui/mod_menu/modpacks/ApplicableModLabel.tscn")
var applicable_mods = {}
var exported_mods = []

func _ready():
	var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	var mods = pointers.ManifestV2.__get_mod_data()["mods"]
	for m in mods:
		var mod = mods[m]
		if mod["manifest"]["has_manifest"]:
			var manifest = mod["manifest"]["manifest_data"]
			if "manifest_url" in manifest.get("manifest_definitions",{}) and "HEVLIB_GITHUB" in manifest.get("links",{}):
				var url = manifest["manifest_definitions"]["manifest_url"]
				var github = manifest["links"]["HEVLIB_GITHUB"].get("URL","")
				if url and github:
					var info = manifest["mod_information"]
					var id = info["id"]
					var mname = info["name"]
					applicable_mods[id] = {"name":mname,"manifest_url":url,"github_url":github}
					exported_mods.append(id)
	for mod in applicable_mods:
		var m = applicable_mods[mod]
		var label = applicable_label.instance()
		label.set_text(m["name"])
		label.modname = mod
		label.data = m.duplicate(true)
		label.parent = self
		label.name = str(hash(mod))
		applicable_list.add_child(label)
		

func toggled(id,how):
	if how:
		if not id in exported_mods:
			exported_mods.append(id)
	else:
		if id in exported_mods:
			exported_mods.erase(id)
