extends Node

var current_level = 0

func _ready():
	pass

func load_next_level():
	current_level += 1
	get_tree().paused = false
	get_tree().change_scene("res://Levels/Level" + str(current_level) + ".tscn")

func relaod_level():
	get_tree().reload_current_scene()
