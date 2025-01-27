@icon("res://assets/textures/ClassIcons16x16/camera.png")
@tool
class_name PlayerCamera extends Node3D
const GROUP: StringName = &"player_camera"

@export_tool_button("Select Camera", "Camera3D") 
var select_camera: Callable = select_camera_in_editor

#@export_range(-180, 180, 2.5, "radians_as_degrees") 
#var starting_pitch: float = deg_to_rad(-30.0)
#
#@export_range(-180, 180, 2.5, "radians_as_degrees") 
#var pitch_min: float = deg_to_rad(-50.0)
#
#@export_range(-180, 180, 2.5, "radians_as_degrees") 
#var pitch_max: float = deg_to_rad(-5.0)

const DISTANCE_FROM_PIVOT: float = 3.0

const CAMERA_OFFSET: Vector3 = Vector3(0, 0.5, 0)


const STARTING_PITCH: float = deg_to_rad(-30.0)
const MIN_PITCH: float =  deg_to_rad(-55.0)
const MAX_PITCH: float =  deg_to_rad(-5.0)



const HORIZONTAL_CAMERA_SENSITIVITY: float = 3.0
const VERTICAL_CAMERA_SENSITIVITY: float = 1.0

@onready var player: Player = get_parent()

var rotation_pivot: Node3D
var cam: Camera3D

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
		cam.rotation.x = STARTING_PITCH


func _ready() -> void:
	_on_att_changed.call_deferred()

func _process(delta: float) -> void:
	position = player.position
	if Engine.is_editor_hint(): return
	if player.input_active:
		process_input(delta)


func process_input(delta: float) -> void:
	const HORIZONTAL_CAMERA_SENSITIVITY: float = 3.0
	const VERTICAL_CAMERA_SENSITIVITY: float = 1.0
	
	var input:= Input.get_vector(&"camera_left", &"camera_right", &"camera_up", &"camera_down", 0.2)
	cam.rotation.x = clampf(cam.rotation.x - input.y * VERTICAL_CAMERA_SENSITIVITY * delta, MIN_PITCH, MAX_PITCH)
	
	rotation_pivot.rotation.y = fmod(rotation_pivot.rotation.y - input.x * HORIZONTAL_CAMERA_SENSITIVITY * delta, TAU)
	#att.yaw = rotation_pivot.global_rotation_degrees.y
	update_position()


func update_position() -> void:
	var pre_offset_position: Vector3 = Vector3.FORWARD.rotated(Vector3.RIGHT, PI + cam.rotation.x) * (DISTANCE_FROM_PIVOT + 0.5)
	cam.position = pre_offset_position + CAMERA_OFFSET



# NOTE: For editor only!
func _on_att_changed() -> void:
	if not is_inside_tree(): 
		await tree_entered
	#update_rotation()
	update_position()

#func get_camera_dir() -> Vector2:
	#var position_deltas := global_position - cam.global_position
	#return Vector2(position_deltas.x, position_deltas.z).normalized()

func get_yaw() -> float:
	return rotation_pivot.rotation.y


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
