extends KinematicBody2D

var speed = 500 

var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("down")



func _physics_process(delta):
	process_input(delta)
	velocity = move_and_slide(velocity)

func process_input(delta):
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		$AnimatedSprite.play("up")
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		$AnimatedSprite.play("down")
		velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		$AnimatedSprite.play("right")
		if not $AnimatedSprite.flip_h:
			$AnimatedSprite.flip_h = true
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		$AnimatedSprite.play("right")
		if $AnimatedSprite.flip_h:
			$AnimatedSprite.flip_h = false
		velocity.x += 1
	velocity = velocity.normalized() * speed
