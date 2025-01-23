class_name CollisionSensor extends Node

const META_TAG: StringName = &"cushion"

signal unsafe_collision(collider: Node)

@onready var body: RigidBody3D = get_parent()
@onready var rid: RID = body.get_rid()

@export var enabled: bool = true
@export_enum("Velocity Delta", "Impulse") var detection_mode: int = 0
@export_enum("None", "Unsafe Only", "All") var debug_level: int = 0

@export var max_safe_linear_delta_magnitude: float = 2.0
@export_range(0.0,30.0, 0.1, "or_greater") var max_safe_impulse: float = 5.0

var linear_velocity: Vector3 = Vector3.ZERO
var current_collider: Node

func _ready() -> void:
	body.can_sleep = false
	body.sleeping = false
	body.contact_monitor = true
	body.continuous_cd = true
	body.max_contacts_reported = 32
	body.body_entered.connect(_on_body_entered)
	linear_velocity = body.linear_velocity

func _physics_process(delta: float) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(rid)
	#
	#var params:=PhysicsTestMotionParameters3D.new()
	##params.exclude_bodies = [rid]
	#
	#params.max_collisions = 32
	#
	##params.shape_rid = PhysicsServer3D.body_get_shape(rid, 0)
	#params.from = body.transform
	#params.motion = body.linear_velocity * delta
	#var result:= PhysicsTestMotionResult3D.new()
	#var is_colliding:= PhysicsServer3D.body_test_motion(rid, params, result)
	#var depth:= result.get_collision_depth()
	#if is_colliding:
		#print("Colliding: %s | Depth: %1.5f" % [is_colliding, result.get_collision_depth()])
	#return
	
	if detection_mode == 1:
		#state.get_
		for i: int in state.get_contact_count():
			var vel:= state.get_contact_impulse(i)
			#body.to_global()
			var normal:= state.get_contact_local_normal(i)
			var global_norm:= body.transform.affine_inverse().orthonormalized() * normal
			var local_vel:= state.get_contact_local_velocity_at_position(i)
			var strength: float = vel.length()
			var vel_dir:= linear_velocity.normalized()
			var dot: float = vel_dir.dot(normal.normalized())
			var magnitude: float = strength * abs(dot)
			if strength > 1.0:
				print("Unsafe Collision - Impulse: %1.02v | Strength: %1.02f | Magnitude: %1.02f | DOT: %1.02f | Normal: %1.02v | Linear: %1.02v" % [vel, strength, magnitude, dot, global_norm, vel_dir])
			if strength > max_safe_impulse:
				unsafe_collision.emit(state.get_contact_collider_object(i))
	
	#set_deferred(&"linear_velocity", body.linear_velocity)
	linear_velocity = body.linear_velocity
	
	#body.test_move()
	#body.get_colliding_bodies()

# TODO: Tweak physics to be more reliable
func handle_collision(collider: Node) -> void:
	var linear_velocity_delta: Vector3 =  body.linear_velocity - linear_velocity
	var linear_strength: float = linear_velocity_delta.length() * collider.get_meta(META_TAG, 1.0)
	
	#var dot: float = body.linear_velocity.normalized().dot(linear_velocity.normalized())
	
	linear_velocity = body.linear_velocity
	
	if max_safe_linear_delta_magnitude < linear_strength:
		if debug_level == 1:
			print("Collision \"%s\" | Str: %1.2f | %1.2v" % [collider.name, linear_strength, linear_velocity_delta])
		unsafe_collision.emit(collider)
	
	if debug_level == 2:
		print("Collision \"%s\" | Str: %1.2f | %1.2v" % [collider.name, linear_strength, linear_velocity_delta])


func _on_body_entered(collider: Node) -> void:
	if enabled and detection_mode == 0: handle_collision(collider)
