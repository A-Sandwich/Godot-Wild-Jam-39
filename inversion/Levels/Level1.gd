extends Node2D

var intro_dialog = "/Level1/Level1Intro"

func _ready():
	if not $"/root/GlobalState".should_trigger_dialog(intro_dialog):
		$Player.can_win = true
		$Player.can_move = true
		return
	get_tree().paused = true
	var new_dialog = Dialogic.start(intro_dialog)
	add_child(new_dialog)
	new_dialog.connect('timeline_end', self, 'after_dialog')
	
func after_dialog(timeline_name):
	get_tree().paused = false
	$Player.pan_to_goal()
	$Player.can_win = true
