extends Node

enum {BUS_MASTER = 0, BUS_SFX = 1, BUS_MUSIC = 2}

var music_stream: AudioStreamPlayer
var sfx_stream: AudioStreamPlayer

const SFX:={
	explosion = preload("res://assets/sfx/explosion_metallic.wav"),
	#moving = preload("res://assets/sfx/explosion_metallic.wav"),
	thud = preload("res://assets/sfx/explosion_metallic.wav"),
	roll = preload("res://assets/sfx/explosion_metallic.wav"),
}


func _init() -> void:
	if Engine.is_editor_hint(): return
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	const BUS_SFX_NAME: StringName = &"SFX"
	const BUS_MUSIC_NAME: StringName = &"Music"
	
	AudioServer.add_bus(BUS_SFX)
	AudioServer.set_bus_name(BUS_SFX, BUS_SFX_NAME)
	
	AudioServer.add_bus(BUS_MUSIC)
	AudioServer.set_bus_name(BUS_MUSIC, BUS_MUSIC_NAME)
	
	preload("res://resources/settings.tres").volume_changed.connect(change_bus_volume)
	
	music_stream = AudioStreamPlayer.new()
	music_stream.bus = BUS_MUSIC_NAME
	music_stream.max_polyphony = 1
	
	sfx_stream = AudioStreamPlayer.new()
	sfx_stream.bus = BUS_SFX_NAME


func change_bus_volume(bus: int, percent_value: float) -> void:
	AudioServer.set_bus_volume_linear(bus, percent_value/100.0)
