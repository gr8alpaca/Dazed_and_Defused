class_name CollisionSensor extends Node

const META_TAG: StringName = &"cushion"

signal unsafe_collision(collider: Node)

@onready var body: RigidBody3D = get_parent()
@onready var rid: RID = body.get_rid()

@export var enabled: bool = true
@export var debug: bool = false : set = set_debug

@export var max_safe_linear_delta_magnitude: float = 2.0

var linear_velocity: Vector3 = Vector3.ZERO
#var current_collider: Node

var raycast: RayCast3D = RayCast3D.new()

var real_velocity: Vector3
var previous_postion: Vector3 

func set_debug(val: bool) -> void:
	debug = val
	raycast.visible = debug

func _ready() -> void:
	body.can_sleep = false
	body.sleeping = false
	body.contact_monitor = true
	body.continuous_cd = true
	body.max_contacts_reported = 32
	PhysicsServer3D.body_set_force_integration_callback(rid, _integrate_forces)
	linear_velocity = body.linear_velocity
	body.add_child.call_deferred(raycast)
	previous_postion = body.position


#func _physics_process(delta: float) -> void:
#
	#var linear_velocity_delta: Vector3 =  body.linear_velocity - linear_velocity
	#var linear_strength: float = linear_velocity_delta.length() #* collider.get_meta(META_TAG, 1.0)
	#
	#if 1.0 < linear_strength:
		#print("Collision: Force: %1.2f | Delta: %1.2v" % [linear_strength, linear_velocity_delta])
	#if max_safe_linear_delta_magnitude < linear_strength:
		##print("Collision: Force: %1.2f | Delta: %1.2v" % [linear_strength, linear_velocity_delta])
		#unsafe_collision.emit(self)
	#linear_velocity = body.linear_velocity


func _integrate_forces(state:PhysicsDirectBodyState3D) -> void:
	var linear_velocity_delta: Vector3 =  state.linear_velocity - linear_velocity
	var linear_strength: float = linear_velocity_delta.length() 
	var cushion:= get_cushion(state)
	var magnitude:= linear_strength * cushion
	if 1.0 < magnitude:
		print("Collision: Force: %1.2f | Delta: %1.2v" % [magnitude, linear_velocity_delta])
	if max_safe_linear_delta_magnitude < magnitude:
		unsafe_collision.emit(self)
		
	linear_velocity = state.linear_velocity




func get_cushion(state: PhysicsDirectBodyState3D) -> float:
	var val: float = 1.0
	for i: int in state.get_contact_count():
		var node:= state.get_contact_collider_object(i)
		if node.has_meta(META_TAG):
			val = node.get_meta(META_TAG, 1.0) if val == 1.0 else minf(val, node.get_meta(META_TAG, 1.0))
	return val

#func _on_body_entered(collider: Node) -> void:
	#if enabled: handle_collision(collider)
