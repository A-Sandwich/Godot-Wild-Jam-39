extends KinematicBody2D

signal control_velocity
signal control_enemy

var is_seen = false
var speed = 400 
var is_falling = false
var is_controlling_enemy = false

var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("down")
	connect_signals_to_enemies()
	self.connect("control_enemy", self, "_control_enemy")
	
func connect_signals_to_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		self.connect("control_velocity", enemy, "_control_velocity")
		self.connect("control_enemy", enemy, "_control_enemy")

func _physics_process(delta):
	process_input()
	velocity = move_and_slide(velocity)

func process_input():
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
	if Input.is_action_just_pressed("ui_select") and not is_seen:
		var enemies = get_tree().get_nodes_in_group("Enemy")
		for enemy in enemies:
			print(global_position.distance_to(enemy.global_position))
			if global_position.distance_to(enemy.global_position) < 75:
				emit_signal("control_enemy", enemy)
	velocity = apply_velocity(velocity)

func apply_velocity(velocity):
	if is_falling:
		return apply_fall()
		
	var result = velocity.normalized() * speed
	emit_signal("control_velocity", result)
	
	if is_controlling_enemy:
		return Vector2.ZERO
	return result

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

func _player_in_fov():
	is_seen = true
	print("I'm seen!")

func _player_out_of_fov():
	is_seen = false
	print("I am hidden!")

func _control_enemy(enemy):
	is_controlling_enemy = true
