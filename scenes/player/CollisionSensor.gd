class_name CollisionSensor extends Node

const META_TAG: StringName = &"cushion"

signal unsafe_collision(collider: Node)

@onready var body: RigidBody3D = get_parent()

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
	var linear_velocity_delta: Vector3 =  body.linear_velocity - linear_velocity
	if not is_collision_safe(linear_velocity_delta, collider):
		unsafe_collision.emit(collider)
	linear_velocity = body.linear_velocity

func is_collision_safe(linear_velocity_delta: Vector3, collider: Node) -> bool:
	var linear_strength: float = linear_velocity_delta.length() * collider.get_meta(META_TAG, 1.0)
	if debug:  print("Collision with %s | Strength: %2.2f" %[collider.name, linear_strength])
	return max_safe_linear_delta_magnitude >= linear_strength



func _on_body_entered(collider: Node) -> void:
	if enabled: handle_collision(collider)
