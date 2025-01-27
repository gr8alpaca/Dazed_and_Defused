@icon("res://assets/textures/ClassIcons16x16/character.png")
@tool
class_name Player extends RigidBody3D
const GROUP: StringName = &"player"

const SCENE_PATH: String = "res://scenes/player/player.tscn"
const ACCELERATION: float = 125.0
const MAX_TILT_DEGREES: float = 20.0

signal dead(collider: Node)

@export_tool_button("Select Camera", "Camera3D")
var select_camera: Callable


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
		$DebugRayCast.visible = val

var camera: PlayerCamera

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
	
	#if OS.is_debug_build() and not Engine.is_editor_hint():
	var raycast:= RayCast3D.new()
	raycast.name = &"DebugRayCast"
	raycast.collide_with_bodies = false
	raycast.collision_mask = 0
	raycast.debug_shape_custom_color = Color(0.957, 0.224, 0.98, 0.361)
	add_child(raycast, true)
	raycast.top_level= true
	#raycast.visible = false
	


func _ready() -> void:
	if Engine.is_editor_hint(): return
	var explosion: GPUParticles3D = $Explosion
	explosion.finished.connect(explosion.set_lifetime.bind(explosion.lifetime), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	explosion.lifetime = 0.01
	explosion.emitting = true
	
	$CollisionSensor.unsafe_collision.connect(_on_unsafe_collision)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Engine.is_editor_hint(): return
	
	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down", 0.1) if input_active else Vector2.ZERO
	
	state.apply_central_force(get_force_vector(state.step))
	
	if debug_raycast:
		var raycast: RayCast3D = $DebugRayCast
		raycast.position = position
		raycast.target_position = state.linear_velocity



func get_force_vector(delta: float,) -> Vector3:
	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down", 0.1) if input_active else Vector2.ZERO
	
	var yaw: float = get_viewport().get_camera_3d().global_rotation.y 
	var local_input: Vector2 = input.rotated(-yaw)
	
	var x_inp: float = local_input.x * 5.0 * tilt_sensitivity
	var z_inp: float = local_input.y * 5.0 * tilt_sensitivity
	
	var x_force: float = x_inp * ACCELERATION * delta
	var z_force: float = z_inp * ACCELERATION * delta
	
	return Vector3(x_force, 0, z_force)
	#


func set_collision_sensor_enabled(enabled: bool) -> void:
	$CollisionSensor.enabled = enabled


func _on_unsafe_collision(collider: Node) -> void:
	$CollisionSensor.enabled = false
	set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)
	$Explosion.visible = true
	$Explosion.emitting = true
	$SphereMesh.hide()
	dead.emit(collider)



func _process(delta: float) -> void:
	if camera and input_active:
		pass
	if not godmode: return
	const GODMODE_SPEED: float = 10.0
	var xz_dir:= Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down", 0.1).rotated(-camera.get_yaw()) * delta
	position += Vector3(xz_dir.x, Input.get_axis(&"crouch", &"jump") * delta, xz_dir.y) * GODMODE_SPEED

func set_godmode(active: bool) -> void:
	godmode = active
	$CollisionSensor.enabled = !godmode
	gravity_scale = 0.0 if godmode else 1.0
	#freeze = godmode
	set_process(godmode)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_pressed(): return
	
	if Input.is_key_pressed(KEY_PAGEUP):
		$CollisionSensor.enabled = !$CollisionSensor.enabled
	
	elif event.is_action_pressed(&"godmode"):
		set_godmode(!godmode)
	
	else:
		return
	
	get_viewport().set_input_as_handled()
