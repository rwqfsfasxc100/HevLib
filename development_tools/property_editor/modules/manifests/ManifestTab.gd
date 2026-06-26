extends Tabs

const MANIFEST_VERSIONS = [
	1.0,
	2.0,
	2.1,
	2.2,
]

onready var manifest_loaders = [
	$HBoxContainer/ScrollContainer/HBoxContainer/VBoxContainer/MV1,
	$HBoxContainer/ScrollContainer/HBoxContainer/VBoxContainer/MV2,
	$HBoxContainer/ScrollContainer/HBoxContainer/VBoxContainer/MV21,
	$HBoxContainer/ScrollContainer/HBoxContainer/VBoxContainer/MV22,
]

func _ready():
	$HBoxContainer/HBoxContainer/IMPORT.connect("pressed",self,"IMPORT")
	$HBoxContainer/HBoxContainer/EXPORT.connect("pressed",self,"EXPORT")
	$HBoxContainer/HBoxContainer/ImportDiag.connect("file_selected",self,"_on_import")
	$HBoxContainer/HBoxContainer/ExportDiag.connect("file_selected",self,"_on_export")
	select_mv(manifest_loaders.size() - 1)

var current_mv : float = 2.2

func select_mv(idx:int):
	for i in manifest_loaders:
		i.visible = false
	manifest_loaders[idx].visible = true
	current_mv = MANIFEST_VERSIONS[idx]

func IMPORT():
	var FD = $HBoxContainer/HBoxContainer/ImportDiag
	var directory = Settings.cfg.last_seen_files.manifest
	FD.set_current_dir(directory)
	FD.popup_centered()
	pass

func _on_import(PATH:String):
	Settings.store_value("last_seen_files","manifest",PATH.get_base_dir())
	var manifest_dta = FormatManifests.parse(PATH)
	manifest_loaders[MANIFEST_VERSIONS.find(manifest_dta.get("manifest_definitions",{}).get("manifest_version",1.0))].IMPORT(manifest_dta)

func _on_export(PATH:String):
	var dir = PATH.get_base_dir()
	Settings.store_value("last_seen_files","manifest",dir)
	var out = manifest_loaders[MANIFEST_VERSIONS.find(current_mv)].EXPORT()
	FormatManifests.format(out,PATH)

func EXPORT():
	var FD = $HBoxContainer/HBoxContainer/ExportDiag
	var directory = Settings.cfg.last_seen_files.manifest
	FD.set_current_dir(directory)
	FD.set_current_file("mod.manifest")
	FD.popup_centered()


