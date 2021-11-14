extends KinematicBody2D

var speed = 400 
var is_falling = false

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
	velocity = apply_velocity(velocity)

func apply_velocity(velocity):
	if is_falling:
		return apply_fall()
	return velocity.normalized() * speed

func apply_fall():
	velocity = Vector2(0, 1)
	velocity = velocity.normalized() * (speed * 2)
	self.z_index = -1
	$Camera2D.current = false
	return velocity

func _on_FallDetection_body_exited(body):
	if get_tree().get_nodes_in_group("Grass").find(body) != -1:
		is_falling = true
		print("Falling")
