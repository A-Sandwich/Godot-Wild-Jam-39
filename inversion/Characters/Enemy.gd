extends KinematicBody2D

signal player_in_fov
signal player_out_of_fov

var speed = 100 
var velocity = Vector2.ZERO
var is_under_player_control = false
var is_falling = false
var rng = RandomNumberGenerator.new()
var direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_signals_to_player()
	connect_to_goal()
	rng.randomize()
	direction = pick_random_direction()

func connect_to_goal():
	var goal = get_tree().get_nodes_in_group("Goal")
	if len(goal) < 1:
		print("Failed to connect to goal")
		return
	goal[0].connect("in_goal", self, "_in_goal")
	
func connect_signals_to_player():
	var player = get_tree().get_nodes_in_group("Player")
	if len(player) < 1:
		print("Failed to get player")
		return
	self.connect("player_in_fov", player[0], "_player_in_fov")
	self.connect("player_out_of_fov", player[0], "_player_out_of_fov")

func _physics_process(delta):
	if is_falling:
		velocity = Vector2(0,1) * (speed * 2)
	if velocity == Vector2.ZERO:
		velocity = direction * speed
	move_and_slide(velocity)
	velocity = Vector2.ZERO

func _control_velocity(velocity):
	if is_under_player_control:
		self.velocity = velocity * -1

func _on_FieldOfView_area_entered(area):
	if (area.get_parent().name == "Player"):
		emit_signal("player_in_fov")

func _on_FieldOfView_area_exited(area):
	if (area.get_parent().name == "Player"):
		emit_signal("player_out_of_fov")

func _control_enemy(enemy):
	if self != enemy:
		return
	
	is_under_player_control = true
	$Camera2D.current = true

func _in_goal(area):
	print("Enemy in goooooal", area.name)

func pick_random_direction():
	return Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)).normalized()

func _on_FallDetection_body_exited(body):
	if is_under_player_control:
		is_falling = true
		z_index = -1
	else:
		direction = direction * -1


func _on_DirectionChange_timeout():
	print("New direction")
	direction = pick_random_direction()
