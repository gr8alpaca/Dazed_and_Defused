@icon("res://assets/textures/ClassIcons16x16/mouse.png")
class_name MouseController extends Node

const SENSITIVITY: float = 0.04

const TEXTURES: InputTextures = preload("res://resources/input_textures.tres")
var disabled: bool = true
#var is_last_device_joypad: bool = false

func _ready() -> void:
	var body: RigidBody3D = get_parent()
	body.input_ray_pickable = true
	body.input_capture_on_drag = true
	body.input_event.connect(_on_input_event.bind(body))
	#set_physics_process(false)

func _physics_process(delta: float) -> void:
	if disabled: return
	const FORCE: float = 10.0
	var input:Vector2 = Input.get_vector(&"camera_left", &"camera_right", &"camera_up", &"camera_down", 0.1).rotated(-get_viewport().get_camera_3d().global_rotation.y).limit_length(1.0)

	get_parent().apply_central_force(Vector3(input.x, 0, input.y) * FORCE)

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, body: RigidBody3D) -> void:
	if disabled: return
	
	if event is InputEventJoypadMotion and event.axis_value > 0.2:
		set_physics_process(true)
	
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_LEFT:
		var input: Vector2 = event.relative.rotated(-camera.global_rotation.y) 
		var force: Vector2 = SENSITIVITY * input
		
		body.apply_central_impulse((Vector3(force.x, 0, force.y)))
		set_physics_process(false)
