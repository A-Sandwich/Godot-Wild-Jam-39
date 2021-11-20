extends Camera2D

var is_panning = false
var target = Vector2.ZERO
var speed = 400
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_panning:
		global_position = global_position.move_toward(target, 5)
	if global_position.distance_to(target) < 10:
		is_panning = false
		target = Vector2.ZERO
		$PanPause.start()

func pan_to_point(point):
	if not is_panning:
		target = point
		is_panning = true


func _on_PanPause_timeout():
	$PanPause.stop()
