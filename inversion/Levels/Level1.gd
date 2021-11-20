extends Node2D

func _ready():
	get_tree().paused = true
	var new_dialog = Dialogic.start('Level1Intro')
	add_child(new_dialog)
	new_dialog.connect('timeline_end', self, 'after_dialog')
	
func after_dialog(timeline_name):
	get_tree().paused = false
	$Player.pan_to_goal()
