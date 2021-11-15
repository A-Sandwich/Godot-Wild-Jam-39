extends KinematicBody2D


var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if velocity != Vector2.ZERO:
		print("Move")
	move_and_slide(velocity)
	velocity = Vector2.ZERO


func _control_velocity(velocity):
	self.velocity = velocity * -1
