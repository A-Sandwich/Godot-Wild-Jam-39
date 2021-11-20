extends KinematicBody2D

signal control_velocity
signal control_enemy
signal control_old_man

var is_seen = false
var speed = 400 
var is_falling = false
var is_using_mind_control = false
var is_panning = false

var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("down")
	connect_signals_to_enemies()
	connect_signals_to_old_men()
	self.connect("control_enemy", self, "_control_enemy")
	self.connect("control_old_man", self, "_control_old_man")
	
func connect_signals_to_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		self.connect("control_velocity", enemy, "_control_velocity")
		self.connect("control_enemy", enemy, "_control_enemy")

func connect_signals_to_old_men():
	var old_men = get_tree().get_nodes_in_group("Old")
	for old_man in old_men:
		self.connect("control_old_man", old_man, "_control_old_man")

func _physics_process(delta):
	if is_panning:
		return
	process_input()
	velocity = move_and_slide(velocity)

func process_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		if not is_using_mind_control: $AnimatedSprite.play("up")
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		if not is_using_mind_control: $AnimatedSprite.play("down")
		velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		if not is_using_mind_control: $AnimatedSprite.play("right")
		if  not is_using_mind_control and not $AnimatedSprite.flip_h:
			$AnimatedSprite.flip_h = true
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		if not is_using_mind_control: $AnimatedSprite.play("right")
		if not is_using_mind_control and $AnimatedSprite.flip_h:
			$AnimatedSprite.flip_h = false
		velocity.x += 1
	if Input.is_action_just_pressed("ui_select") and not is_seen:
		var enemy_found = select_enemy()
		if not enemy_found:
			select_old_man()
	velocity = apply_velocity(velocity)

func select_old_man():
	var old_man = get_tree().get_nodes_in_group("Old")
	if len(old_man) < 1:
		print("Can't find the old man")
		return
	if global_position.distance_to(old_man[0].global_position) < 50:
		emit_signal("control_old_man", old_man[0])

func select_enemy():
	var enemy_found = false
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) < 50:
			emit_signal("control_enemy", enemy)
			enemy_found = true
	return enemy_found

func apply_velocity(velocity):
	if is_falling:
		return apply_fall()
		
	var result = velocity.normalized() * speed
	emit_signal("control_velocity", result)
	
	if is_using_mind_control:
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
	is_using_mind_control = true

func _control_old_man(old_man):
	is_using_mind_control = true

func _enemy_died():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		if enemy.is_under_player_control and not enemy.is_falling:
			emit_signal("control_enemy", enemy)
			return
	$Camera2D.current = true
	is_using_mind_control = false

func pan_to_goal():
	is_panning = true
	$Camera2D.pan_to_point(get_goal_location())

func get_goal_location():
	var goal = get_tree().get_nodes_in_group("Goal")
	if len(goal) < 1:
		print("Failed to connect to goal")
		return global_position
	return goal[0].global_position


func _on_PanPause_timeout():
	$Camera2D.global_position = global_position
	is_panning = false
