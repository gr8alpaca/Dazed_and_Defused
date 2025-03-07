@icon("res://assets/textures/ClassIcons16x16/camera.png")
@tool
class_name PlayerCamera extends Node3D
const GROUP: StringName = &"player_camera"

const SETTINGS: Settings = preload("res://resources/settings.tres")

@export_tool_button("Select Camera", "Camera3D") 
var select_camera: Callable = select_camera_in_editor

const DISTANCE_FROM_PIVOT: float = 3.0

const CAMERA_OFFSET: Vector3 = Vector3(0, 0.5, 0)

const STARTING_PITCH: float = deg_to_rad(-30.0)
const MIN_PITCH: float =  deg_to_rad(-55.0)
const MAX_PITCH: float =  deg_to_rad(-5.0)

const VERTICAL_CAMERA_SENSITIVITY_RATIO: float = 0.4

const TOUCH_SENSITIVITY_MODIFIER: float = 0.002
const GAMEPAD_SENSITIVITY_MODIFIER: float = 0.005

@onready var player: Player = get_parent()

var rotation_pivot: Node3D
var cam: Camera3D

var drag_index: int = 0
var last_position: Vector2


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group(GROUP)
	top_level = true
	
	if not rotation_pivot: 
		rotation_pivot = Node3D.new()
		cam = Camera3D.new()
		add_child(rotation_pivot, false, Node.INTERNAL_MODE_BACK)
		rotation_pivot.add_child(cam,)
		rotation_pivot.owner = self
		cam.owner = self
		cam.rotation.x = STARTING_PITCH

func _ready() -> void:
	update_position()

func _process(delta: float) -> void:
	position = player.position
	move_camera(Input.get_vector(&"camera_left", &"camera_right", &"camera_up", &"camera_down", SETTINGS.get_camera_deadzone()) \
	* SETTINGS.get_camera_sensitivity() * delta  )

func move_camera(input: Vector2) -> void:
	if not player.input_active: return
	input.limit_length(1.0)
	cam.rotation.x = clampf(cam.rotation.x - input.y * VERTICAL_CAMERA_SENSITIVITY_RATIO, MIN_PITCH, MAX_PITCH)
	rotation_pivot.rotation.y = fmod(rotation_pivot.rotation.y - input.x, TAU)
	update_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		drag_index = event.index if event.pressed and not event.canceled else 0
		last_position = event.position
		
	elif event is InputEventScreenDrag and drag_index == event.index:
		if event.is_canceled():
			drag_index = 0
		else:
			move_camera((event.position - last_position) * SETTINGS.get_camera_sensitivity() * TOUCH_SENSITIVITY_MODIFIER)
			last_position = event.position
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		move_camera(event.relative * SETTINGS.get_camera_sensitivity() * TOUCH_SENSITIVITY_MODIFIER)
	
	else:
		return
	
	#get_viewport().set_input_as_handled()


func update_position() -> void:
	var pre_offset_position: Vector3 = Vector3.FORWARD.rotated(Vector3.RIGHT, PI + cam.rotation.x) * (DISTANCE_FROM_PIVOT + 0.5)
	cam.position = pre_offset_position + CAMERA_OFFSET

func get_yaw() -> float:
	return rotation_pivot.rotation.y

func select_camera_in_editor() -> void:
	if not Engine.has_singleton(&"EditorInterface"): return
	var select = Engine.get_singleton(&"EditorInterface").get_selection()
	select.clear()
	select.add_node(cam)

func shake() -> void:
	const DURATION_SEC: float = 0.6
	
	const MAX_YAW: float = deg_to_rad(0.0)
	const YAW_LOOPS: int = 10
	const YAW_TWEEN_TIME: float = DURATION_SEC/YAW_LOOPS/4.0
	
	const MAX_PITCH: float = deg_to_rad(2.0)
	const PITCH_LOOPS: int = 7
	const PITCH_TWEEN_TIME: float = DURATION_SEC/PITCH_LOOPS/4.0
	
	const MAX_ROLL: float = deg_to_rad(3.0)
	const ROLL_LOOPS: int = 5
	const ROLL_TWEEN_TIME: float = DURATION_SEC/ROLL_LOOPS/4.0
	
	#var yaw_tw: Tween = create_tween()
	#for i: int in YAW_LOOPS:
		#var value: float = lerp(MAX_YAW, 0.0, inverse_lerp(0, YAW_LOOPS, i))
		#yaw_tw.tween_property(self, ^"rotation:y", value, YAW_TWEEN_TIME).as_relative()
		#yaw_tw.tween_property(self, ^"rotation:y", -value*2.0, YAW_TWEEN_TIME).as_relative()
		#yaw_tw.tween_property(self, ^"rotation:y", value, YAW_TWEEN_TIME).as_relative()
		
	var pitch_tw: Tween = create_tween()
	for i: int in PITCH_LOOPS:
		var value: float = lerp(MAX_PITCH, 0.0, inverse_lerp(0, PITCH_LOOPS, i))
		pitch_tw.tween_property(self, ^"rotation:x", value, PITCH_TWEEN_TIME).as_relative()
		pitch_tw.tween_property(self, ^"rotation:x", -value*2.0, PITCH_TWEEN_TIME).as_relative()
		pitch_tw.tween_property(self, ^"rotation:x", value, PITCH_TWEEN_TIME).as_relative()
	
	var roll_tw: Tween = create_tween()
	for i: int in ROLL_LOOPS:
		var value: float = lerp(MAX_ROLL, 0.0, inverse_lerp(0, ROLL_LOOPS, i))
		roll_tw.tween_property(self, ^"rotation:z", value, ROLL_TWEEN_TIME).as_relative()
		roll_tw.tween_property(self, ^"rotation:z", -value*2.0, ROLL_TWEEN_TIME).as_relative()
		roll_tw.tween_property(self, ^"rotation:z", value, ROLL_TWEEN_TIME).as_relative()

	
