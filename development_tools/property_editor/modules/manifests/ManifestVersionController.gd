extends OptionButton

export (NodePath) var ManifestController = NodePath("../../..")
onready var manifest = get_node_or_null(ManifestController)

const MANIFEST_VERSION_NAMES = [
	"1",
	"2",
	"2.1",
	"2.2"
]

func _ready():
	connect("item_selected",self,"_on_item_selected")
	for i in MANIFEST_VERSION_NAMES:
		add_item(i)
	select(get_item_count() - 1)

func _on_item_selected(idx:int):
	manifest.select_mv(idx)
