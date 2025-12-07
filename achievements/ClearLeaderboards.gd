extends Popup

const leaderboards = [
	"best_haul",
	"best_ore",
	"longest_dive",
	"longest_dive_realtime",
	"money_per_day",
	"time",
	"total_money",
]

var current_stat = ""

onready var warning = $PanelContainer/Control/WipeStatConfirm

var steamNode = null

func _ready():
	for i in Achivements.get_children():
		if i.has_method("updateLeaderboard"):
			steamNode = i
	if steamNode == null:
		for i in $PanelContainer/VBoxContainer/VBoxContainer.get_children():
			i.visible = false
		var label = Label.new()
		label.name = "HEVLIB_NOSTEAM"
		label.text = "HEVLIB_NOSTEAM"
		$PanelContainer/VBoxContainer/VBoxContainer.add_child(label)








func _unhandled_input(event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		if warning.visible:
			warning.hide()
		else:
			cancel()
		get_tree().set_input_as_handled()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")
func show_menu():
	popup_centered()

func cancel():
	hide()
	refocus()
	Tool.remove(self)


func _about_to_show():
	lastFocus = get_focus_owner()
	var firstBTN = get_node_or_null("PanelContainer/VBoxContainer/VBoxContainer/best_haul/Button")
	var closeBTN = get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Button")
	if firstBTN.visible:
		firstBTN.grab_focus()
	else:
		closeBTN.grab_focus()
	

func showWarning(stat):
	current_stat = stat
	warning.dialog_text = TranslationServer.translate("HEVLIB_WIPE_STAT_ARE_YOU_SURE") % stat
	warning.popup_centered()


func _on_WipeStatConfirm_confirmed():
	if steamNode:
		steamNode.keepBest = false
		steamNode.updateLeaderboard(current_stat,0)
		steamNode.keepBest = true

func _on_best_haul_pressed():
	showWarning("best_haul")


func _on_best_ore_pressed():
	showWarning("best_ore")


func _on_longest_dive_pressed():
	showWarning("longest_dive")


func _on_longest_dive_realtime_pressed():
	showWarning("longest_dive_realtime")


func _on_money_per_day_pressed():
	showWarning("money_per_day")


func _on_time_pressed():
	showWarning("time")


func _on_total_money_pressed():
	showWarning("total_money")
