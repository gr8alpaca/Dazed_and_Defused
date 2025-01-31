@icon("res://assets/textures/ClassIcons16x16/sound.png")
class_name PlayerAudio extends Node3D

var player: Player

const LINEAR_VELOCITY_TRESHOLD: float = 1.0

const MIN_LINEAR_VELOCITY: float = 0.0
const MAX_LINEAR_VELOCITY: float = 5.0

const LINEAR_RATIO_ROLL_SFX: float = 0.7

const MIN_DB: float = -80.0

const MAX_DB_DELTA: float = 80.0

var roll_stream: AudioStreamPlayer3D
var thud_stream: AudioStreamPlayer3D


func _ready() -> void:
	roll_stream = AudioStreamPlayer3D.new()
	thud_stream = AudioStreamPlayer3D.new()
	roll_stream.bus = &"SFX"
	thud_stream.bus = &"SFX"
	roll_stream.stream = preload("res://assets/sfx/thunder-roll-trimmed.wav")
	thud_stream.stream = preload("res://assets/sfx/hit-metallic-basketball-hoop-supports.wav") 
	
	roll_stream.volume_db = MIN_DB
	
	
	add_child(roll_stream)
	add_child(thud_stream) 
	
	roll_stream.play()
	create_tween().tween_callback(roll_stream.play).set_delay(3.0)
	
	player = get_parent()
	player.dead.connect(_on_dead)
	
	PhysicsServer3D.body_set_force_integration_callback(player.get_rid(), integrate_forces)
	#Player.SETTINGS.volume_changed.connect(_on_volume_changed)

func play_defused() -> void:
	thud_stream.stop()
	thud_stream.stream = Audio.SFX_LIBRARY.extinguish
	thud_stream.play()


func _physics_process(delta: float) -> void:
	if not player.get_contact_count():
		roll_stream.volume_db = move_toward(roll_stream.volume_db, MIN_DB, delta * MAX_DB_DELTA)
		return
	
	var linear:= player.linear_velocity.length()
	var t:= clampf(inverse_lerp(MIN_LINEAR_VELOCITY, MAX_LINEAR_VELOCITY, linear), 0.0, 1.0) * Player.SETTINGS.get_sfx_volume()/100.0 * LINEAR_RATIO_ROLL_SFX
	#var target_db:= lerpf(MIN_DB, MAX_DB, t)
	
	const SOUND_FALLOFF_RATE: float = 0.2
	var delta_modifier: float = 0.2 if roll_stream.volume_db > t else 1.0
	roll_stream.volume_linear = move_toward(roll_stream.volume_linear, t, delta )
	#roll_stream.volume_db = move_toward(roll_stream.volume_db, target_db, delta * MAX_DB_DELTA * delta_modifier )


func integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	const THRESHOLD: float = 3.5
	for i: int in state.get_contact_count():
		var impulse:= state.get_contact_impulse(i)
		if impulse.length() < THRESHOLD: continue
		thud_stream.play()
		#print("Thud Played @\t%3.2f..." % (Time.get_ticks_msec() / 1000.0))
		break


func _on_dead(collider: Node) -> void:
	thud_stream.stop()
	if collider is DeathBox:
		return
	thud_stream.process_mode = Node.PROCESS_MODE_ALWAYS
	thud_stream.stream = Audio.SFX_LIBRARY.explosion
	thud_stream.play()
