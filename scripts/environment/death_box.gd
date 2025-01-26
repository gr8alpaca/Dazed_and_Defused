@icon("res://assets/textures/ClassIcons16x16/skull.png")
@tool
class_name DeathBox extends Area3D
const GROUP: StringName = &"deathbox"



func _ready() -> void:
	add_to_group(GROUP)
	var death_cam : Camera3D = Camera3D.new()
	add_child(death_cam, false, Node.INTERNAL_MODE_FRONT)
	death_cam.current = false
	death_cam.owner = self
	
	monitorable = false
	collision_layer = 0
	collision_mask = 2
	var collision_shape:= CollisionShape3D.new()
	collision_shape.shape = WorldBoundaryShape3D.new()
	collision_shape.debug_fill = false
	add_child(collision_shape)
	collision_shape.owner = self
	if Engine.is_editor_hint(): return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body is Player: return
	assert(is_inside_tree(), "Deathbox method '_on_body_entered' called outside of tree.")
	const TWEEN_TIME_SEC: float = 0.3
	
	var player: Player = body
	var player_camera: Camera3D = get_viewport().get_camera_3d()
	var death_camera : Camera3D = get_death_camera()
	if not player.is_inside_tree(): return
	player.input_active = false
	death_camera.global_transform = player_camera.global_transform
	death_camera.current = true
	
	var tw: Tween = create_tween().set_parallel()
	tw.tween_property(death_camera, ^"global_rotation:x", -PI/2.0, TWEEN_TIME_SEC)
	tw.tween_property(death_camera, ^"global_rotation:z", 0.0, TWEEN_TIME_SEC)
	tw.tween_property(death_camera, ^"global_position", 
			player.global_position + Vector3(0, death_camera.global_position.distance_to(player.global_position), 0), TWEEN_TIME_SEC)
	
	player.dead.emit(self)


func get_death_camera() -> Camera3D:
	return get_child(0, true)
