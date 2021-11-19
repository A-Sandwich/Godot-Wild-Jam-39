extends Node2D

func _ready():
	get_tree().paused = true
	var new_dialog = Dialogic.start('Intro')
	add_child(new_dialog)
	new_dialog.connect('timeline_end', self, 'after_dialog')
	new_dialog.connect('dialogic_signal', self, 'pan_to_goal')
	
func after_dialog(timeline_name):
	print(timeline_name)
	get_tree().paused = false

func _select_dialog(dialog_name):
	get_tree().paused = true
	var new_dialog = Dialogic.start(dialog_name)
	add_child(new_dialog)
	new_dialog.connect('timeline_end', self, 'after_dialog')

func pan_to_goal(name):
	print("IN")
	$Player.pan_to_goal()
