extends Node

var current_level = 0
var triggered_dialog = []

func _ready():
	pass

func load_next_level():
	current_level += 1
	get_tree().paused = false
	get_tree().change_scene("res://Levels/Level" + str(current_level) + ".tscn")

func relaod_level():
	get_tree().reload_current_scene()

func should_trigger_dialog(dialog_name):
	if dialog_name in triggered_dialog:
		return false
	triggered_dialog.append(dialog_name)
	return true
