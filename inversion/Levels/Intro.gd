extends Node2D

var intro_dialog = "/Intro/Intro"

func _ready():
	if not $"/root/GlobalState".should_trigger_dialog(intro_dialog):
		$Player.can_move = true
		return
	get_tree().paused = true
	var new_dialog = Dialogic.start(intro_dialog)
	add_child(new_dialog)
	new_dialog.connect('timeline_end', self, 'after_dialog')
	new_dialog.connect('dialogic_signal', self, 'pan_to_goal')
	
func after_dialog(timeline_name):
	get_tree().paused = false

func _select_dialog(dialog_name):
	get_tree().paused = true
	var new_dialog = Dialogic.start(dialog_name)
	add_child(new_dialog)
	new_dialog.connect('timeline_end', self, 'after_dialog')

func pan_to_goal(name):
	$Player.pan_to_goal()
