@tool
class_name Level extends Node3D

signal goal_reached

func _on_goal_entered(player: Node3D) -> void:
	print("Level Complete!")
	player.get_node(^"CollisionSensor").enabled = false
	player.input_active = false
	player.linear_damp = 10.0
	goal_reached.emit()
