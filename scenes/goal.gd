@tool
class_name Goal extends Area3D
#
@export_range(0.0, 360.0, 5.0, "radians_as_degrees") var spin_speed_sec: float = PI/2.0
@export_range(0.05, 5.0, 0.05, "suffix:m") var rise_speed_sec: float = 2.0

@onready var text_mesh: MeshInstance3D = $CylinderMesh/Text

var time: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint() or not get_parent() is Level: return
	body_entered.connect(get_parent()._on_goal_entered)
	#var text_mesh: MeshInstance3D = $CylinderMesh/Text
	#var tw: Tween = text_mesh.create_tween()
	#tw.twee

func _process(delta: float) -> void:
	time = fmod(delta/rise_speed_sec + time, 1.0)
	const MAX_RISE_DISTANCE: float = 0.25 
	
	#position_offset = fmod(position_offset + delta * rise_speed_sec, rise_speed_sec*2.0)
	text_mesh.rotation.y = fmod(text_mesh.rotation.y + spin_speed_sec * delta, TAU)
	text_mesh.position.y = 0.75 + cos(time * TAU) * MAX_RISE_DISTANCE

#func _on_body_entered(node: Node) -> void:
	#var player: Player = node as Player
	#player.input_active = true

#const MATERIAL_GOAL: StandardMaterial3D = preload("res://resources/materials/goal.tres") 
#
#

#func _init() -> void:
	#var mesh: MeshInstance3D = MeshInstance3D.new()
	#add_child(mesh, false, INTERNAL_MODE_FRONT)
	#pass
#
#


#func _get_property_list() -> Array[Dictionary]:
	#
	#return []
#
#
#func _set(property: StringName, value: Variant) -> bool:
	#match property:
		#&"height":
			#set_cylinder_props(height)
	#return false
#
#func set_cylinder_props(height: float = 0.0, radius: float = 0.0) -> void:
	#var mesh: MeshInstance3D = get_child(0, true)
	#var col: CollisionShape3D = get_child(1, true)
	#
