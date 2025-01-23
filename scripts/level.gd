@icon("res://assets/textures/ClassIcons16x16/world.png")
@tool
class_name Level extends Node3D

signal goal_reached

func _on_goal_entered(player: Node3D) -> void:
	#print("Level Complete!")
	player.set_collision_sensor_enabled(false)
	player.input_active = false
	player.linear_damp = 10.0
	goal_reached.emit()
	Master.change_level(Master.current_level + 1)
