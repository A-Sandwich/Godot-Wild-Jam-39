extends KinematicBody2D

signal person_in_fov
signal player_out_of_fov
signal enemy_died
signal control_enemy

export var is_guarding_goal = false
export var is_stationary = false
export var is_old_man = false

var can_move = false
var can_win = false
var speed = 100 
var velocity = Vector2.ZERO
var is_under_player_control = false
var is_falling = false
var rng = RandomNumberGenerator.new()
var direction = Vector2.ZERO
var goal_coordinates
const WIN = preload("res://HUD/Win.tscn")
const LOSE = preload("res://HUD/Lose.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_signals_to_player()
	connect_signals_to_old_man()
	connect_to_goal()
	rng.randomize()
	direction = pick_random_direction()
	connect_signals_to_enemies()
	
func connect_signals_to_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		if enemy != self:
			self.connect("control_enemy", enemy, "_control_enemy")


func connect_to_goal():
	var goal = get_tree().get_nodes_in_group("Goal")
	if len(goal) < 1:
		print("Failed to connect to goal")
		return
	goal[0].connect("in_goal", self, "_in_goal")
	if is_guarding_goal:
		goal_coordinates = goal[0].global_position

func connect_signals_to_player():
	var player = get_tree().get_nodes_in_group("Player")
	if len(player) < 1:
		print("Failed to get player")
		return
	self.connect("person_in_fov", player[0], "_person_in_fov")
	self.connect("player_out_of_fov", player[0], "_player_out_of_fov")
	self.connect("enemy_died", player[0], "_enemy_died")

func connect_signals_to_old_man():
	var old_man = get_tree().get_nodes_in_group("Old")
	if len(old_man) < 1:
		print("Failed to get old man")
		return
	self.connect("person_in_fov", old_man[0], "_person_in_fov")

func _physics_process(delta):
	if not can_move:
		return
	if is_falling:
		velocity = Vector2(0,1) * (speed * 6)
	if velocity == Vector2.ZERO and not is_under_player_control and not is_stationary:
		velocity = direction * speed
	process_input()
	rotate_towards_direction()
	choose_proper_animation()
	move_and_slide(velocity)
	velocity = Vector2.ZERO

func process_input():
	if is_under_player_control:
		if Input.is_action_just_pressed("ui_select"):
			print("Selecting enemy?")
			if not select_enemy():
				print("Can't find")
			else:
				print("Found")

func select_enemy():
	var enemy_found = false
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) < 50 and enemy != self:
			emit_signal("control_enemy", enemy)
			enemy_found = true
	return enemy_found

func choose_proper_animation():
	# This code is bad and I feel bad
	var angle = rad2deg(direction.angle()) -90
	if angle < 0:
		angle = 360 + angle
	
	if  ((0 < angle and angle < 45) or (315 < angle and angle < 360)) and $AnimatedSprite.animation != "down":
		$AnimatedSprite.play("down")
		return
	if (135 < angle and angle < 225) and $AnimatedSprite.animation != "up":
		$AnimatedSprite.play("up")
		return

	if (225 < angle and angle < 315):
		if $AnimatedSprite.animation != "right":
			$AnimatedSprite.play("right")
		$AnimatedSprite.flip_h = false
		return
	if (45 < angle and angle < 135):
		if $AnimatedSprite.animation != "right":
			$AnimatedSprite.play("right")
		$AnimatedSprite.flip_h = true
		return

func rotate_towards_direction():
	if is_stationary:
		return
	
	$FieldOfView.rotation = direction.angle() + -90

func _control_velocity(velocity):
	if is_under_player_control:
		self.velocity = velocity * -1

func _on_FieldOfView_area_entered(area):
	if is_under_player_control:
		return
	if (area.name != "FieldOfView" and (area.get_parent().name == "Player" or
	area.get_parent().name == "OldMan")):
		var lose = LOSE.instance()
		add_child(lose)
		get_tree().paused = true
		emit_signal("person_in_fov")

func _on_FieldOfView_area_exited(area):
	if (area.get_parent().name == "Player"):
		emit_signal("player_out_of_fov")

func _control_enemy(enemy):
	if self != enemy:
		return
	print("Under control")
	$FieldOfView.visible = false
	is_under_player_control = true
	$Camera2D.current = true

func _in_goal(area):
	if (can_win and
	not is_falling and
	is_under_player_control and 
	area.name != "FieldOfView" and
	area.get_parent() == self):
		var win = WIN.instance()
		add_child(win)
		get_tree().paused = true

func pick_random_direction():
	return Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)).normalized()

func _on_FallDetection_body_exited(body):
	if is_under_player_control:
		is_falling = true
		z_index = -1
		$FallTimer.start()
		emit_signal("enemy_died")
		$Camera2D.current = false
	else:
		direction = direction * -1


func _on_DirectionChange_timeout():
	if is_stationary:
		return #love all these conditionals in all of my signals me too
	if is_guarding_goal:
		if is_guarding_goal:
			direction = self.global_position.direction_to(goal_coordinates)
			return
	direction = pick_random_direction()


func _on_FallTimer_timeout():
	queue_free()

func _enemy_can_move():
	can_move = true
