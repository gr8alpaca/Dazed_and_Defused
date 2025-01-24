@icon("res://assets/textures/ClassIcons16x16/camera.png")
@tool
class_name PlayerCamera extends Node3D
const GROUP: StringName = &"player_camera"

@export_tool_button("Select Camera", "Camera3D") 
var select_camera: Callable = select_camera_in_editor

@export var att: ControllerAttributes:
	set(val):
		att = val
		att.pivot_distance_changed.connect(update_position)
		if not att.changed.is_connected(_on_att_changed):
			att.changed.connect(_on_att_changed)


var rotation_pivot: Node3D

var cam: Camera3D

var tilt_cam: bool = false


func _init() -> void:
	add_to_group(GROUP)
	top_level = true
	
	if not rotation_pivot: 
		rotation_pivot = Node3D.new()
		cam = Camera3D.new()
		add_child(rotation_pivot, false, Node.INTERNAL_MODE_BACK)
		rotation_pivot.add_child(cam,)
		rotation_pivot.owner = self
		cam.owner = self

func _ready() -> void:
	_on_att_changed.call_deferred()

func _process(delta: float) -> void:
	position = get_parent().position

func update_cam(input: Vector2, state: PhysicsDirectBodyState3D) -> void:
	assert(is_inside_tree(), "Method 'update_cam' called outside of tree!")
	var rotation_delta: float = att.tilt_speed * state.step

	var target_pitch: float = lerpf(0.0, att.pitch_limit_deg, -input.y)
	att.pitch = move_toward(att.pitch, target_pitch, rotation_delta)

	var target_roll: float = lerpf(0.0, att.roll_limit_deg, input.x)
	
	
	att.roll = move_toward(att.roll, target_roll, rotation_delta)
	update_rotation()
	update_yaw(state)
	update_position()

func update_position() -> void:
	
	var pre_offset_position: Vector3 = Vector3.FORWARD.rotated(Vector3.RIGHT, PI + cam.global_rotation.x) * (att.distance_from_pivot + 0.5)
	cam.position = pre_offset_position + Vector3(0, att.camera_y_offset, 0)


func update_rotation() -> void:
	cam.global_rotation_degrees.x = att.initial_dive_angle_deg + att.pitch if tilt_cam else att.initial_dive_angle_deg
	cam.global_rotation_degrees.z = att.roll if tilt_cam else 0.0


func update_yaw(state: PhysicsDirectBodyState3D) -> void:
	const YAW_SPEED: float = 0.2
	const VELOCITY_CAM_MAX_SPEED: float = 30.0
	const MAX_RADIANS_PER_SECOND: float = PI
	const DEFAULT_VELOCITY_DIR := Vector2.UP
	
	var vel_dir: Vector2 = Vector2(state.linear_velocity.x, state.linear_velocity.z, )
	#var cam_dir: Vector2 = get_camera_dir()
	var vel_norm: Vector2 = vel_dir.normalized()
	var ang_delta: float = vel_norm.angle() - DEFAULT_VELOCITY_DIR.angle()
	var t: float = (vel_dir.length() * state.step)
	
	var rotated_angle: float = lerp_angle(rotation_pivot.global_rotation.y, -ang_delta, t)
	var max_move: float = state.step * MAX_RADIANS_PER_SECOND
	var new_ang: float = move_toward(rotation_pivot.global_rotation.y, rotated_angle, max_move)
	rotation_pivot.global_rotation.y = new_ang

	att.yaw = rotation_pivot.global_rotation_degrees.y

# NOTE: For editor only!
func _on_att_changed() -> void:
	if not is_inside_tree(): 
		await tree_entered
	update_rotation()
	update_position()

#func get_camera_dir() -> Vector2:
	#var position_deltas := global_position - cam.global_position
	#return Vector2(position_deltas.x, position_deltas.z).normalized()

func get_yaw() -> float:
	return rotation_pivot.rotation.y

func set_att(att: ControllerAttributes) -> PlayerCamera:
	self.att = att
	#if Engine.is_editor_hint(): _on_att_changed()
	return self

func select_camera_in_editor() -> void:
	if not Engine.has_singleton(&"EditorInterface"): return
	var select = Engine.get_singleton(&"EditorInterface").get_selection()
	select.clear()
	select.add_node(cam)


#func _notification(what: int) -> void:
	#pass


#func _on_edited_object_changed(inspector: EditorInspector) -> void:
	#print("Object changed...")
	#
#
#func _get_property_list() -> Array[Dictionary]:
	#var props: Array[Dictionary] 
	#props.assign(ClassDB.class_get_property_list(&"Camera3D", true))
	#props.push_front({ "name": "Camera3D", "class_name": &"", "type": 0, "hint": 0, "hint_string": "Camera3D", "usage": 128 })
	#return props
#
#func _get(property: StringName) -> Variant:
	#return cam.get(property) if property in ClassDB.class_get_property_list(&"Camera3D", true).map(func(d: Dictionary) -> StringName: return d.name) else null
#
#func _set(property: StringName, value: Variant) -> bool:
	#if property in ClassDB.class_get_property_list(&"Camera3D", true).map(func(d: Dictionary) -> StringName: return d.name):
		#cam.set(property, value)
		#notify_property_list_changed()
		#return true
	#return false
