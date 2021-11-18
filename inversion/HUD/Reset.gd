extends TextureButton


func _ready():
	pass


func _on_Reset_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
