class_name CollisionSensor extends Node

const META_TAG: StringName = &"cushion"

signal unsafe_collision(collider: Node)

@onready var body: RigidBody3D = get_parent()
@onready var rid: RID = body.get_rid()

@export var enabled: bool = true:
	set(val):
		enabled = val
		if enabled:
			#position = body.position
			enable_buffer = ENABLE_BUFFER_MAX
			#velocity = (body.position - position) / delta
@export var debug: bool = false #: set = set_debug

@export var max_safe_linear_delta_magnitude: float = 2.0

#var linear_velocity: Vector3 = Vector3.ZERO
#var current_collider: Node

#var raycast: RayCast3D = RayCast3D.new()

var velocity: Vector3
var position: Vector3 

var last_collider: Node

const ENABLE_BUFFER_MAX: int = 5
var enable_buffer: int = 0
#
#func set_debug(val: bool) -> void:
	#debug = val
	#raycast.visible = debug

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
	var velocity_delta: Vector3 = real_velocity - velocity
	
	velocity = real_velocity
	position = body.position
	
	#last_collider = last_collider if bodies.is_empty() else bodies[0]
	if enable_buffer > 0:
		enable_buffer -= 1
	if not enabled or enable_buffer: return
	
	var bodies:= body.get_colliding_bodies()
	var linear_strength:= velocity_delta.length()
	var cushion: float = last_collider.get_meta(META_TAG, 1.0) if last_collider else 1.0
	var strength: float = linear_strength * cushion
	
	if max_safe_linear_delta_magnitude < strength:
		print("Collision: Force: %1.2f | Delta: %1.2v | Delta: %1.2f" % [linear_strength, velocity_delta, cushion])
		unsafe_collision.emit(bodies.front())


func get_cushion() -> float:
	var val: float = 1.0
	for node in body.get_colliding_bodies():
		if node.has_meta(META_TAG):
			val = node.get_meta(META_TAG, 1.0) if val == 1.0 else minf(val, node.get_meta(META_TAG, 1.0))
	return val

func _on_body_entered(collider: Node) -> void:
	last_collider = collider
