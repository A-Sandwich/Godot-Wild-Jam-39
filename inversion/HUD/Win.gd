extends CanvasLayer


func _ready():
	pass


func _on_NextLevelButton_pressed():
	$"/root/GlobalState".load_next_level()
