class_name CollisionSensor extends Node

const META_TAG: StringName = &"cushion"

signal unsafe_collision(collider: Node)

@onready var body: RigidBody3D = get_parent()
@onready var rid: RID = body.get_rid()

@export var enabled: bool = true
@export var debug: bool = false

@export var max_safe_linear_delta_magnitude: float = 2.0

var linear_velocity: Vector3 = Vector3.ZERO


func _ready() -> void:
	body.can_sleep = false
	body.sleeping = false
	body.contact_monitor = true
	body.continuous_cd = true
	body.max_contacts_reported = 10
	body.body_entered.connect(_on_body_entered)
	linear_velocity = body.linear_velocity

func _physics_process(delta: float) -> void:
	linear_velocity = body.linear_velocity


func handle_collision(collider: Node) -> void:
	var dot: float = body.linear_velocity.normalized().dot(linear_velocity.normalized())
	if not is_collision_safe(collider):
		unsafe_collision.emit(collider)
	
# TODO: Tweak physics to be more reliable
func is_collision_safe(collider: Node3D) -> bool:
	#var state:= PhysicsServer3D.body_get_direct_state(rid)
	#var vels: PackedVector3Array
	#var output: String = " | Vel: "
	#for i: int in state.get_contact_count():
		#vels.push_back(state.get_contact_local_velocity_at_position(i))
		#output += "%01.2v" % vels[-1]
	#print("Contact Count: %s" % state.get_contact_count() + output)
	#
	var linear_velocity_delta: Vector3 =  body.linear_velocity - linear_velocity
	var linear_strength: float = linear_velocity_delta.length() * collider.get_meta(META_TAG, 1.0)
	#var dot: float = body.linear_velocity.normalized().dot(linear_velocity_delta.normalized())
	#var magnitude: float = linear_strength * abs(1.0 - dot)/2.0 
	#print("Collider %s | Strength: %2.2f | DOT: %2.3f | magnitude: %2.3f" %[collider.name, linear_strength, dot, magnitude])
	#if debug:  print("Collision with %s | Strength: %2.2f" %[collider.name, linear_strength])
	linear_velocity = body.linear_velocity
	return max_safe_linear_delta_magnitude >= linear_strength



func _on_body_entered(collider: Node) -> void:
	if enabled: handle_collision(collider)
