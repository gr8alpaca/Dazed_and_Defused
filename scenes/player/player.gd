@icon("res://assets/textures/ClassIcons16x16/character.png")
@tool
class_name Player extends RigidBody3D
const GROUP: StringName = &"player"

const ACCELERATION: float = 175.0
const MAX_TILT_DEGREES: float = 20.0

signal dead(collider: Node)

@export_tool_button("Select Camera", "Camera3D") 
var select_camera: Callable

@export var att: ControllerAttributes = ControllerAttributes.new():
	set(val):
		att = val
		camera.set_att(att)

@export var input_active: bool = true:
	set(val):
		input_active = val
		set_process_input(val)
		set_process_unhandled_input(val)

@export_category("Movement")

@export_range(1.0, 4.0, 0.2, "or_greater", "or_less")
var tilt_sensitivity: float = 1.0

@export_range(-180.0, 180.0, 5.0, "radians_as_degrees") 
var starting_camera_angle: float = 0.0:
	set(val):
		starting_camera_angle = val
		if not is_node_ready():
			await ready
		camera.rotation_pivot.global_rotation.y = starting_camera_angle


var camera: PlayerCamera

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var data: Dictionary = {"Input": Vector2(), "LinVel": 0.0, "pitch": 0.0, "roll": 0.0, "yaw": 0.0, "scale": Vector3.ONE}


func _init() -> void:
	add_to_group(GROUP)
	camera = PlayerCamera.new()
	select_camera = camera.select_camera_in_editor
	add_child(camera)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	$CollisionSensor.unsafe_collision.connect(_on_unsafe_collision)
	

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Engine.is_editor_hint(): return
	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down", 0.05) if input_active else Vector2.ZERO
	
	var yaw: float = camera.get_yaw()
	var local_input: Vector2 = input.rotated(-yaw)
	#input = input.rotated(-yaw)
	
	var x_inp: float = local_input.x * 5.0 * tilt_sensitivity
	var z_inp: float = local_input.y * 5.0 * tilt_sensitivity
	
	var x_force: float = x_inp * ACCELERATION * state.step
	var z_force: float = z_inp * ACCELERATION * state.step
	state.apply_central_force(Vector3(x_force, 0, z_force))
	
	camera.update_cam(input, state)
	
	data["Input"] = input
	data["LinVel"] = linear_velocity
	for prop: String in ["roll", "pitch", "yaw"]:
		data[prop] = att.get(prop)


func set_collision_sensor_enabled(enabled: bool) -> void:
	$CollisionSensor.enabled = enabled

func _on_unsafe_collision(collider: Node) -> void:
	set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)
	$Explosion.emitting = true
	$SphereMesh.hide()
	dead.emit(collider)
	
