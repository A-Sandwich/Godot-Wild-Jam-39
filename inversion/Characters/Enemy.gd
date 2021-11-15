extends KinematicBody2D

signal player_in_fov
signal player_out_of_fov

var velocity = Vector2.ZERO
var is_under_player_control = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_signals_to_player()
	connect_to_goal()

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
