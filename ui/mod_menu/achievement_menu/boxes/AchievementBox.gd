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
onready var progress_button : Button = $MarginContainer/HBoxContainer/Progress/MarginContainer/Button
onready var progress_bar_label : Label = $MarginContainer/HBoxContainer/Progress/MarginContainer/Label

onready var pointers : HevLibPointers = ModLoader._savedObjects[0]

var uses_tooltip : bool = false

var menu_container : Popup = null
var mod_menu : Popup = null

func _ready() -> void:
	button.connect("pressed",self,"on_label_button_pressed")
	connect("visibility_changed",self,"_vis_changed")

func update_data() -> void:
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
		var handled_addit : bool = false
		if stat and not is_unlocked:
			var raw_stat : String = "stat:" + stat
			var stat_max : float = associated_data.limit
			if stat.begins_with("PLAYTIME_") or stat == "manual":
				var stat_value : float = pointers.Achievements.__get_stat_data(raw_stat)
				progress_bar.value = stat_value
				icon.value = stat_value
				progress_bar_label.text = Tool.readableTimeSpan(stat_value,true) + " / " + Tool.readableTimeSpan(stat_max,true)
				var additional_data = associated_data.data
				if additional_data is Array:
					var tooltip : String = TranslationServer.translate("HEVLIB_ACHDESC_SUPPORTED_HARDWARE")
					for i in additional_data:
						tooltip += "\n\t" + TranslationServer.translate(i)
					progress_button.hint_tooltip = tooltip
					uses_tooltip = true
					handled_addit = true
			elif stat.begins_with("max_money") or stat.begins_with("max_insurance"):
				if stat.ends_with("_k"):
					stat = stat.trim_suffix("_k")
					raw_stat = raw_stat.trim_suffix("_k")
					stat_max *= 1000.0
				elif stat.ends_with("_m"):
					stat = stat.trim_suffix("_m")
					raw_stat = raw_stat.trim_suffix("_m")
					stat_max *= 1000000.0
				var stat_value : float = pointers.Achievements.__get_stat_data(raw_stat)
				progress_bar.value = stat_value
				icon.value = stat_value
				progress_bar_label.text = CurrentGame.formatThousands(stat_value) + " E$ / " + CurrentGame.formatThousands(stat_max) + " E$"
			elif stat == "maxDepth":
				var stat_value : float = pointers.Achievements.__get_stat_data(raw_stat)
				progress_bar.value = stat_value
				icon.value = stat_value
				progress_bar_label.text = CurrentGame.formatThousands(stat_value) + " km / " + CurrentGame.formatThousands(stat_max) + " km"
			elif stat == "leaf" or stat == "max_players" or stat == "salvaged_ships":
				var stat_value : float = pointers.Achievements.__get_stat_data(raw_stat)
				progress_bar.value = stat_value
				icon.value = stat_value
				progress_bar_label.text = CurrentGame.formatThousands(stat_value) + " / " + CurrentGame.formatThousands(stat_max)
			else:
				pointers.l("UNKNOWN STAT \"%s\": please double check if vanilla only and implement if so" % stat,"MM2 Achievement Menu")
				
				breakpoint
			progress_label.text = raw_stat
			progress_bar.max_value = stat_max
			icon.max_value = stat_max
		else:
			icon.max_value = 1
			if is_unlocked:
				icon.value = 1
				menu_container.achievement_list.move_child(self,menu_container.completed_achievement_count)
				menu_container.completed_achievement_count += 1
				progress_container.visible = false
			else:
				if mod_menu.is_in_game:
					var additional_data = associated_data.data
					if additional_data is Dictionary:
						var t_max : int = 0
						var t_val : int = 0
						for story_flag in additional_data.keys():
							var story_val : int = CurrentGame.getStory(story_flag)
							if story_val > -1:
								var story_data : Array = additional_data[story_flag]
								if story_val > story_data[1]:
									continue
								var s_max : int = story_data[0]
								t_max += s_max
								t_val += min(story_val,s_max)
						if t_max < 1:
							progress_container.visible = false
						else:
							progress_bar.max_value = t_max
							icon.max_value = t_max
							icon.value = t_val
							progress_bar.value = t_val
							progress_label.text = "MM2_STORY_FLAG_STAT_" + achievement_id
							pointers.l("Registered story-based achievement: " + progress_label.text,"MM2 Achievement Menu")
							progress_bar_label.text = CurrentGame.formatThousands(t_val) + " / " + CurrentGame.formatThousands(t_max)
					else:
						progress_container.visible = false
				else:
					icon.value = 0
					progress_container.visible = false
			
	
	visible = true
	$AnimateAppear.play("show")

func _vis_changed():
	if is_visible_in_tree() and get_position_in_parent() == 0:
		button.emit_signal("pressed")

func on_label_button_pressed():
	button.get_child(0).call_deferred("scrollTo")
	if uses_tooltip and progress_container.visible:
		progress_button.grab_focus()

