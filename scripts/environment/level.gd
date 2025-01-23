@icon("res://assets/textures/ClassIcons16x16/world.png")
@tool
class_name Level extends Node3D

signal player_dead(collider: Node)
signal goal_reached

func _ready() -> void:
	for goal: Goal in find_children("*", "Goal"):
		goal.body_entered.connect(_on_goal_entered.bind(goal), CONNECT_ONE_SHOT)
	find_child("Player").dead.connect(_on_dead)

func _on_dead(collider: Node) -> void:
	player_dead.emit(collider)

func _on_goal_entered(player: Node3D, goal: Goal) -> void:
	player.set_collision_sensor_enabled(false)
	player.input_active = false
	player.linear_damp = 10.0
	goal_reached.emit()
	Master.change_level(Master.current_level + 1)
