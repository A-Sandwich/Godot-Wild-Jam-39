extends KinematicBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_input(delta)

func process_input(delta):
	if Input.is_action_pressed("ui_up"):
		pass
	if Input.is_action_pressed("ui_down"):
		pass
	if Input.is_action_pressed("ui_left"):
		pass
	if Input.is_action_just_pressed("ui_right"):
		pass
