@icon("res://assets/textures/ClassIcons16x16/sound.png")
class_name PlayerAudio extends Node3D

var player: Player

const LINEAR_VELOCITY_TRESHOLD: float = 1.0

const MIN_LINEAR_VELOCITY: float = 0.0
const MAX_LINEAR_VELOCITY: float = 5.0

const MIN_DB: float = -80.0
const MAX_DB: float = -10.0

const MAX_DB_DELTA: float = 80.0

var roll_stream: AudioStreamPlayer3D
var thud_stream: AudioStreamPlayer3D


func _ready() -> void:
	roll_stream = AudioStreamPlayer3D.new()
	thud_stream = AudioStreamPlayer3D.new()
	roll_stream.bus = &"SFX"
	thud_stream.bus = &"SFX"
	roll_stream.stream = preload("res://assets/sfx/thunder-roll-trimmed.wav")
	thud_stream.stream = preload("res://assets/sfx/metal-thud.wav")
	
	roll_stream.volume_db = MIN_DB
	#thud_stream.stop()
	
	add_child(roll_stream)
	add_child(thud_stream)
	
	roll_stream.play()
	create_tween().tween_callback(roll_stream.play).set_delay(3.0)
	
	player = get_parent()
	player.get_node(^"CollisionSensor").collision.connect.call_deferred(_on_collision)
	player.dead.connect(_on_dead)
	
	#player.body_entered.connect(_on_collision)

func _physics_process(delta: float) -> void:
	#
	
	if not player.get_contact_count():
		roll_stream.volume_db = move_toward(roll_stream.volume_db, MIN_DB, delta * MAX_DB_DELTA)
		return
	
	var linear:= player.linear_velocity.length()
	var t:= clampf(inverse_lerp(MIN_LINEAR_VELOCITY, MAX_LINEAR_VELOCITY, linear), 0.0, 1.0)
	var target_db:= lerpf(MIN_DB, MAX_DB, t)
	
	var delta_modifier: float = 0.5 if roll_stream.volume_db > target_db else 1.0
	roll_stream.volume_db = move_toward(roll_stream.volume_db, target_db, delta * MAX_DB_DELTA * delta_modifier )


func _on_collision(strength: float) -> void:
	if strength > 200.0:
		print("PLAYING THUD...")
		thud_stream.play()

func _on_dead(collider: Node) -> void:
	thud_stream.stop()
	thud_stream.process_mode = Node.PROCESS_MODE_ALWAYS
	thud_stream.stream = preload("res://assets/sfx/explosion_metallic.wav")
	thud_stream.play()
	
