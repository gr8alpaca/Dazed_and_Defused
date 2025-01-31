@tool
class_name Goal extends Area3D

@onready var text_mesh: MeshInstance3D = $CylinderMesh/Text
@export_range(-5, 5, 1, ) var goal_level_increment: int = 1

var time: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false


func _process(delta: float) -> void:
	const SPIN_SPEED: float = PI/2.0
	const RISE_SPEED: float = 3.0
	const MAX_RISE_DISTANCE: float = 0.25 
	time = fmod(delta/RISE_SPEED + time, 1.0)
	
	text_mesh.rotation.y = fmod(text_mesh.rotation.y + SPIN_SPEED * delta, TAU)
	text_mesh.position.y = 0.75 + cos(time * TAU) * MAX_RISE_DISTANCE
