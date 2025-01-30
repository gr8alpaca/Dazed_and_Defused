class_name CollisionSensor extends Node

const META_TAG: StringName = &"cushion"

signal collision(strength: float)
signal unsafe_collision(collider: Node)

@onready var body: RigidBody3D = get_parent()
@onready var rid: RID = body.get_rid()

@export var enabled: bool = true:
	set(val):
		enabled = val
		if enabled:
			enable_buffer = ENABLE_BUFFER_MAX

@export var max_safe_linear_delta_magnitude: float = 2.0

var velocity: Vector3
var position: Vector3 

var last_collider: Node

const ENABLE_BUFFER_MAX: int = 5
var enable_buffer: int = 5

func _ready() -> void:
	body.can_sleep = false
	body.sleeping = false
	body.contact_monitor = true
	body.continuous_cd = true
	body.max_contacts_reported = 32
	position = body.position
	
	body.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	var real_velocity: Vector3 = (body.position - position) / delta
	var velocity_delta: Vector3 = (real_velocity - velocity) / delta
	
	velocity = real_velocity
	position = body.position
	
	if enable_buffer > 0:
		enable_buffer -= 1
	
	var linear_strength:= velocity_delta.length()
	
	if enable_buffer: return
	
	collision.emit(linear_strength)
	
	if not enabled: return
	
	
	
	var cushion: float = last_collider.get_meta(META_TAG, 1.0) if last_collider else 1.0
	var strength: float = linear_strength * cushion
	
	if max_safe_linear_delta_magnitude < strength:
		print("Velocity: %1.2v | Collision: Force: %1.2f | Delta: %1.2v | Cushion: %1.2f" % [real_velocity, linear_strength, velocity_delta, cushion])
		unsafe_collision.emit(last_collider)


func get_cushion() -> float:
	var val: float = 1.0
	for node in body.get_colliding_bodies():
		if node.has_meta(META_TAG):
			val = node.get_meta(META_TAG, 1.0) if val == 1.0 else minf(val, node.get_meta(META_TAG, 1.0))
	return val

func _on_body_entered(collider: Node) -> void:
	last_collider = collider
