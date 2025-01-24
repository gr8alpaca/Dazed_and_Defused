@icon("res://assets/textures/ClassIcons16x16/character.png")
@tool
class_name Player extends RigidBody3D
const GROUP: StringName = &"player"

const SCENE_PATH: String = "res://scenes/player/player.tscn"
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
		camera.rotation_pivot.rotation.y = starting_camera_angle

@export var debug_raycast: bool = false:
	set(val):
		debug_raycast = val
		get_node(^"DebugRayCast").visible = val
		
var camera: PlayerCamera
#var raycast: RayCast3D

#var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var data: Dictionary = {"Input": Vector2(), "LinVel": 0.0, "pitch": 0.0, "roll": 0.0, "yaw": 0.0, "scale": Vector3.ONE}
var godmode: bool = false

func _init() -> void:
	add_to_group(GROUP)
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.4
	camera = PlayerCamera.new()
	select_camera = camera.select_camera_in_editor
	add_child(camera)
	if OS.is_debug_build():
		var raycast:= RayCast3D.new()
		raycast.name = &"DebugRayCast"
		raycast.collide_with_bodies = false
		raycast.collision_mask = 0
		raycast.debug_shape_custom_color = Color(0.957, 0.224, 0.98, 0.361)
		add_child(raycast, true)
		raycast.top_level= true
		raycast.visible = false
	


func _ready() -> void:
	if Engine.is_editor_hint(): return
	$CollisionSensor.unsafe_collision.connect(_on_unsafe_collision)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Engine.is_editor_hint(): return
	#$CollisionSensor._integrate_force(state)
	
	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down", 0.05) if input_active else Vector2.ZERO
	
	if godmode:
		handle_godmode(state, input)
		return
	
	var yaw: float = camera.get_yaw()
	var local_input: Vector2 = input.rotated(-yaw)
	#input = input.rotated(-yaw)
	
	var x_inp: float = local_input.x * 5.0 * tilt_sensitivity
	var z_inp: float = local_input.y * 5.0 * tilt_sensitivity
	
	var x_force: float = x_inp * ACCELERATION * state.step
	var z_force: float = z_inp * ACCELERATION * state.step
	var prev_lin:= state.linear_velocity
	state.apply_central_force(Vector3(x_force, 0, z_force))
	
	#var collision:= KinematicCollision3D.new()
	#if test_move(global_transform, linear_velocity, collision, 0.001, false, 32):
		#pass
	
	#print("%1.2v -> %1.2v" % [prev_lin, state.linear_velocity])
	
	
	camera.update_cam(input, state)
	
	data["Input"] = input
	data["LinVel"] = linear_velocity
	for prop: String in ["roll", "pitch", "yaw"]:
		data[prop] = att.get(prop)
	
	if debug_raycast:
		var raycast: RayCast3D = $DebugRayCast
		raycast.position = position
		raycast.target_position = state.linear_velocity
	#linear_velocity * state.step
	#$SphereMesh.global_rotation += linear_velocity * Vector3(1,1,-1) * state.step

func set_collision_sensor_enabled(enabled: bool) -> void:
	$CollisionSensor.enabled = enabled


func _on_unsafe_collision(collider: Node) -> void:
	set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)
	$Explosion.emitting = true
	$SphereMesh.hide()
	dead.emit(collider)

func handle_godmode(state: PhysicsDirectBodyState3D, input: Vector2) -> void:
	pass

func set_godmode(active: bool) -> void:
	godmode = active
	$CollisionSensor.enabled = !godmode
	freeze = godmode


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_pressed(): return
	
	if Input.is_key_pressed(KEY_PAGEUP):
		$CollisionSensor.enabled = !$CollisionSensor.enabled
		
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_INSERT):
		set_godmode(!godmode)
