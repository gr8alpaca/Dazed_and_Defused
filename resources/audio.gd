extends Node

enum {BUS_MASTER = 0, BUS_MUSIC = 1, BUS_SFX = 2,}

var music_stream: AudioStreamPlayer
var sfx_stream: AudioStreamPlayer

const SFX_LIBRARY:={
	explosion = preload("res://assets/sfx/explosion_metallic.wav"),
	extinguish =  preload("res://assets/sfx/cig_extinguish.wav"),
	defused = preload("res://assets/sfx/defused.wav"),
}

const MUSIC_LIBRARY:={
	main_theme = preload("res://assets/music/main_theme.wav"),
}

func _init() -> void:
	if Engine.is_editor_hint(): return
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	const BUS_SFX_NAME: StringName = &"SFX"
	const BUS_MUSIC_NAME: StringName = &"Music"
	
	AudioServer.add_bus(BUS_MUSIC)
	AudioServer.set_bus_name(BUS_MUSIC, BUS_MUSIC_NAME)
	
	AudioServer.add_bus(BUS_SFX)
	AudioServer.set_bus_name(BUS_SFX, BUS_SFX_NAME)
	
	
	music_stream = AudioStreamPlayer.new()
	music_stream.bus = BUS_MUSIC_NAME
	music_stream.max_polyphony = 1
	add_child(music_stream)
	
	sfx_stream = AudioStreamPlayer.new()
	sfx_stream.volume_db
	sfx_stream.bus = BUS_SFX_NAME
	sfx_stream.max_polyphony = 10
	add_child(sfx_stream)
	
	preload("res://resources/settings.tres").volume_changed.connect(change_bus_volume)


func change_bus_volume(bus: int, percent_value: float) -> void:
	
	match bus:
		BUS_MUSIC:
			music_stream.volume_db = linear_to_db(percent_value/100.0)
		BUS_SFX:
			sfx_stream.volume_db = linear_to_db(percent_value/100.0)
			if get_tree().current_scene:
				get_tree().current_scene.propagate_call(&"set_volume_linear", [percent_value/100.0])
			

func play_sfx(track: AudioStream) -> void:
	sfx_stream.stream = track
	sfx_stream.play()

func play_music(track: AudioStream) -> void:
	#const SETTINGS:= preload("res://resources/settings.tres")
	if music_stream.stream != track:
		music_stream.stream = track
	
	if not music_stream.playing:
		music_stream.play()

func pause_music() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(music_stream, ^"volume_linear", 0.0, 1.0)
	tw.tween_callback(music_stream.stop)
	tw.tween_property(music_stream, ^"volume_linear", preload("res://resources/settings.tres").get_music_volume()/100.0, 1.0)
	
