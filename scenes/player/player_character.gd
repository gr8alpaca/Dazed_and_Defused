
@tool
class_name Character extends CharacterBody3D
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

var camera: PlayerCamera

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var data: Dictionary = {"Input": Vector2(), "LinVel": 0.0, "pitch": 0.0, "roll": 0.0, "yaw": 0.0, "scale": Vector3.ONE}

var godmode: bool = false


func _ready() -> void:
	add_to_group(GROUP)
	#physics_material_override = PhysicsMaterial.new()
	#physics_material_override.friction = 0.4
	camera = PlayerCamera.new()
	select_camera = camera.select_camera_in_editor
	add_child(camera)
	

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	get_position_delta()
