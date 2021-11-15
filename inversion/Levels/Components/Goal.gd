extends Node2D

signal in_goal

func _ready():
	pass


func _on_Area2D_area_entered(area):
	print("Something is in the goal")
	emit_signal("in_goal", area)
