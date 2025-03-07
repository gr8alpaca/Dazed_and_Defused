@icon("res://assets/textures/ClassIcons16x16/character.png")
@tool
class_name Player extends RigidBody3D
const GROUP: StringName = &"player"

const SCENE_PATH: String = "res://scenes/player/player.tscn"
const ACCELERATION: float = 125.0
const MAX_TILT_DEGREES: float = 20.0

const SETTINGS: Settings = preload("res://resources/settings.tres")

signal dead(collider: Node)

@export_tool_button("Select Camera", "Camera3D")
var select_camera: Callable

var input_active: bool = true:
	set(val):
		input_active = val
		set_process_input(val)
		set_process_unhandled_input(val)
		camera.set_process_unhandled_input(val)

@export_category("Movement")

@export_range(1.0, 4.0, 0.2, "or_greater", "or_less")
var tilt_sensitivity: float = 1.0

@export_range(-180.0, 180.0, 5.0, "radians_as_degrees") 
var starting_camera_angle: float = 0.0:
	set(val):
		starting_camera_angle = val
		camera.rotation_pivot.rotation.y = starting_camera_angle

var camera: PlayerCamera

func _init() -> void:
	add_to_group(GROUP)
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.4
	camera = PlayerCamera.new()
	select_camera = camera.select_camera_in_editor
	add_child(camera)


func _ready() -> void:
	if Engine.is_editor_hint(): return
	$CollisionSensor.unsafe_collision.connect(_on_unsafe_collision)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Engine.is_editor_hint(): return
	var input: Vector2 = get_input() 
	state.apply_central_force(get_force_vector(state.step, input))


func get_force_vector(delta: float, input: Vector2) -> Vector3:
	input = to_local_input(input) * SETTINGS.get_movement_sensitivity()/3.0
	input = input.limit_length(1.0) * 5.0 * ACCELERATION * delta
	return Vector3(input.x, 0, input.y)


func get_input() -> Vector2:
	if not input_active: 
		return Vector2.ZERO
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down", SETTINGS.get_movement_deadzone())

func set_collision_sensor_enabled(enabled: bool) -> void:
	$CollisionSensor.enabled = enabled


func _on_unsafe_collision(collider: Node) -> void:
	$CollisionSensor.enabled = false
	set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)
	$Explosion.visible = true
	$Explosion.emitting = true
	$SphereMesh.hide()
	if SETTINGS.get_camera_shake():
		camera.shake()
	
	dead.emit(collider)


func defuse() -> void:
	$SphereMesh/StemMesh/GPUParticles3D.emitting = false
	$PlayerAudio.play_defused()
	
	if randi() % 2: 
		Audio.play_sfx(Audio.SFX_LIBRARY.defused)

func to_local_input(input: Vector2) -> Vector2:
	return input.rotated(-get_camera_yaw())

func get_camera_yaw() -> float:
	return get_viewport().get_camera_3d().global_rotation.y
