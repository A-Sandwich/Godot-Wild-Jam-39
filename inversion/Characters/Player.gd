extends KinematicBody2D

signal control_velocity
signal control_enemy
signal enemy_can_move
signal control_old_man

const WIN = preload("res://HUD/Win.tscn")

var is_seen = false
var speed = 400 
var is_falling = false
var is_using_mind_control = false
var is_panning = false
var can_move = false
var can_win = false

var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("down")
	connect_signals_to_enemies()
	connect_signals_to_old_men()
	connect_to_goal()
	self.connect("control_enemy", self, "_control_enemy")
	self.connect("control_old_man", self, "_control_old_man")
	
func connect_signals_to_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		self.connect("control_velocity", enemy, "_control_velocity")
		self.connect("control_enemy", enemy, "_control_enemy")
		self.connect("enemy_can_move", enemy, "_enemy_can_move")

func connect_signals_to_old_men():
	var old_men = get_tree().get_nodes_in_group("Old")
	for old_man in old_men:
		self.connect("control_old_man", old_man, "_control_old_man")

func connect_to_goal():
	var goal = get_tree().get_nodes_in_group("Goal")
	if len(goal) < 1:
		print("Failed to connect to goal")
		return
	goal[0].connect("in_goal", self, "_in_goal")

func _physics_process(delta):
	if is_panning:
		return
	process_input()
	velocity = move_and_slide(velocity)

func process_input():
	if not can_move:
		return
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

func _person_in_fov():
	print("Player")
	is_seen = true
	print("I'm seen!")

func _player_out_of_fov():
	is_seen = false
	print("I am hidden!")

func _control_enemy(enemy):
	is_using_mind_control = true

func _control_old_man(old_man):
	is_using_mind_control = true

func is_currently_controlling_an_enemy():
	var is_currently_controlling = false
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		if enemy.is_under_player_control and not enemy.is_falling:
			is_currently_controlling = true
	return is_currently_controlling
	
func _enemy_died():
	if is_currently_controlling_an_enemy():
			return
	$Camera2D.current = true
	$ControlTransferTimeout.start()

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
	emit_signal("enemy_can_move")
	can_move = true

func _in_goal(area):
	if (can_win and
	not is_falling and
	not is_using_mind_control and 
	area.name != "FieldOfView" and
	area.get_parent() == self):
		var win = WIN.instance()
		add_child(win)
		get_tree().paused = true


func _on_ControlTransferTimeout_timeout():
	$ControlTransferTimeout.stop()
	if is_currently_controlling_an_enemy():
			return
	is_using_mind_control = false
