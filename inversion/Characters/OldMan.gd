extends KinematicBody2D

signal in_goal
signal select_dialog
signal person_in_fov
signal player_out_of_fov

const WIN = preload("res://HUD/Win.tscn")
const LOSE = preload("res://HUD/Lose.tscn")

var is_seen = false
var is_under_player_control = false
var velocity = Vector2.ZERO
var is_falling = false
var speed = 400 

func _ready():
	connect_to_goal()
	connect_to_parent()
	connect_signals_to_player()

func connect_to_parent():
	self.connect("select_dialog", get_parent(),"_select_dialog")

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
	self.connect("person_in_fov", player[0], "_person_in_fov")
	self.connect("player_out_of_fov", player[0], "_player_out_of_fov")\


func _physics_process(delta):
	if is_under_player_control:
		process_input()

func process_input():
	if is_seen:
		return
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
	if is_falling:
		velocity = Vector2(0,1) * (speed * 6)
		move_and_slide(velocity)
	else:
		velocity = apply_velocity(velocity)

func apply_velocity(velocity):
	var result = velocity.normalized() * speed
	move_and_slide(result * -1)
	return result

func _on_FieldOfView_area_entered(area):
	if not is_under_player_control and area.get_parent().name == "Player":
		emit_signal("select_dialog", "/I SEE YOU")
		print("PERSON")
		emit_signal("person_in_fov")
		#var new_dialog = Dialogic.start('I SEE YOU')
		#add_child(new_dialog)

func _control_old_man(old_man):
	if self != old_man:
		return
	
	$FieldOfView.visible = false
	is_under_player_control = true
	$Camera2D.current = true
	$Explain.start()

func _in_goal(area):
	if area.name == "FieldOfView":
		return
	if is_under_player_control and area.get_parent() == self:
		var win = WIN.instance()
		add_child(win)
		get_tree().paused = true
		
	print("Enemy in goooooal", area.name)


func _on_Explain_timeout():
	if not is_falling:
		emit_signal("select_dialog" ,"Inversion Detected")
	$Explain.stop()

func _on_FallDetection_body_exited(body):
	if is_under_player_control:
		is_falling = true
		z_index = -1
		$FallTimer.start()
		emit_signal("enemy_died")
		$Camera2D.current = false


func _on_FallTimer_timeout():
	var lose = LOSE.instance()
	lose.lablel_text = "You killed the old man . . . try again?"
	get_parent().add_child(lose)
	queue_free()

func _person_in_fov():
	is_seen = true


func _on_FieldOfView_area_exited(area):
	if (area.get_parent().name == "Player"):
		emit_signal("player_out_of_fov")
