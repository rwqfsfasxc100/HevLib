extends Label

onready var modpacks_handle = get_node_or_null(NodePath("../../../../../../../ModpacksMenu/base/VBoxContainer/ApplicableMods"))

var pointers = ModLoader._savedObjects[0]
func _ready():
	get_tree().connect("files_dropped",self,"_files_dropped")

func _files_dropped(files,screen):
	if is_visible_in_tree() and pointers:
			for file in files:
				if file.ends_with(".zip"):
					pointers.FileAccess.__precache_mod_file(file)
				elif file.ends_with(".dvmodpack"):
					if modpacks_handle:
						modpacks_handle._on_OpenPack_file_selected(file)
