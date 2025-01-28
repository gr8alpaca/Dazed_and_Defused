extends Node

enum {BUS_MASTER = 0, BUS_SFX = 1, BUS_MUSIC = 2}

func _init() -> void:
	AudioServer.add_bus(BUS_SFX)
	AudioServer.set_bus_name(BUS_SFX, "SFX")
	
	AudioServer.add_bus(BUS_MUSIC)
	AudioServer.set_bus_name(BUS_MUSIC, "Music")
	
	if not Engine.is_editor_hint():
		preload("res://resources/settings.tres").volume_changed.connect(change_bus_volume)

func change_bus_volume(bus: int, percent_value: float) -> void:
	AudioServer.set_bus_volume_linear(bus, percent_value/100.0)
