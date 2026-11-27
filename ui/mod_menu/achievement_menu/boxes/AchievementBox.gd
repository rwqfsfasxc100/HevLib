extends HBoxContainer

var achievement_id : String = ""

var file : File = File.new()

onready var icon : TextureProgress = $TextureProgress
onready var button : Button = $MarginContainer/Button
onready var name_label : Label = $MarginContainer/HBoxContainer/Labels/NAME
onready var desc_label : Label = $MarginContainer/HBoxContainer/Labels/DESC

onready var progress_container : VBoxContainer = $MarginContainer/HBoxContainer/Progress
onready var progress_label : Label = $MarginContainer/HBoxContainer/Progress/Label
onready var progress_bar : ProgressBar = $MarginContainer/HBoxContainer/Progress/MarginContainer/ProgressBar
onready var progress_bar_label : Label = $MarginContainer/HBoxContainer/Progress/MarginContainer/Label

onready var pointers : HevLibPointers = ModLoader._savedObjects[0]

func _ready() -> void:
	if achievement_id:
		var name_format : String = "ACHIEVEMENT_" + achievement_id
		name_label.text = name_format
		desc_label.text = name_format + "_DESC"
		
		var achievement_icon_dir : String = "res://HevLib Achievement Icons/achievement_icons/"
		var locked_icon_path : String = achievement_icon_dir + achievement_id + "_L.stex"
		var unlocked_icon_path : String = achievement_icon_dir + achievement_id + "_U.stex"
		if file.file_exists(locked_icon_path) and file.file_exists(unlocked_icon_path):
			var lstex : StreamTexture = StreamTexture.new()
			lstex.load_path = locked_icon_path
			icon.texture_under = lstex
			var ustex : StreamTexture = StreamTexture.new()
			ustex.load_path = unlocked_icon_path
			icon.texture_progress = ustex
		var associated_data : Dictionary = pointers.Achievements.__get_achievement_data(achievement_id)
		var stat : String = associated_data.stat
		var is_unlocked : bool = associated_data.isUnlocked
		if stat and not is_unlocked:
#			var stat_data = associated_data.data
			var raw_stat : String = "stat:" + stat
			progress_label.text = raw_stat
			var stat_max : float = associated_data.limit
			progress_bar.max_value = stat_max
			icon.max_value = stat_max
			if stat.begins_with("PLAYTIME_"):
				var stat_value : float = pointers.Achievements.__get_stat_data(raw_stat)
				progress_bar.value = stat_value
				icon.value = stat_value
				progress_bar_label.text = Tool.readableTimeSpan(stat_value,true) + " / " + Tool.readableTimeSpan(stat_max,true)
#				breakpoint
				
		else:
			icon.max_value = 1
			if is_unlocked:
				icon.value = 1
			else:
				icon.value = 0
			progress_container.visible = false
		
		
#		breakpoint



