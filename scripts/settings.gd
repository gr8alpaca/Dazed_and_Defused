@icon("res://assets/textures/ClassIcons16x16/settings_save.png")
@tool
class_name Settings extends Resource

const PATH: String = "user://settings.tres"

const PROPERTIES: PackedStringArray = ["movement_sensitivity", "movment_deadzone", "camera_sensitivity", "camera_deadzone", "master_volume", "sfx_volume", "music_volume",]

signal volume_changed(bus: int, value: float)

@export_range(0.1, 15.0, 0.1, "exp")
var movement_sensitivity: float = 3.0:
	set(val):
		movement_sensitivity = val
		#remap(val, )
		ease_value = lerpf(9.0, 0.05, val/15.0)

var ease_value: float = 15.0

@export_range(0.1, 1.0, 0.1) 
var movment_deadzone: float = 0.2:
	set(val):
		movment_deadzone = val
		for action: StringName in [&"move_up", &"move_right", &"move_left", &"move_down"]:
			if not InputMap.has_action(action): continue
			InputMap.action_set_deadzone(action, val)

@export_range(0.1, 15.0, 0.1, "exp") 
var camera_sensitivity: float = 3.0

@export_range(0.1, 1.0, 0.1)
var camera_deadzone: float = 0.2:
	set(val):
		camera_deadzone = val
		for action: StringName in [&"camera_up", &"camera_right", &"camera_left", &"camera_down"]:
			if not InputMap.has_action(action): continue
			InputMap.action_set_deadzone(action, val)

@export_range(1.0, 100.0, 1.0, "suffix:%")
var master_volume: float = 100.0:
	set(val):
		master_volume = val
		volume_changed.emit(Audio.BUS_MASTER, val)

@export_range(1.0, 100.0, 1.0, "suffix:%")
var sfx_volume: float = 100.0:
	set(val):
		sfx_volume = val
		volume_changed.emit(Audio.BUS_SFX, val)

@export_range(1.0, 100.0, 1.0, "suffix:%") 
var music_volume: float = 100.0:
	set(val):
		music_volume = val
		volume_changed.emit(Audio.BUS_MUSIC, val)

func save_settings() -> void:
	ResourceSaver.save(duplicate(), PATH, ResourceSaver.FLAG_CHANGE_PATH)

func load_settings() -> void:
	if Engine.is_editor_hint(): return
	
	if not ResourceLoader.exists(PATH, "Settings"): 
		print("Settings resource does not exist...")
		return
	print("Settings loading...")
	var settings: Settings = ResourceLoader.load(PATH, "Settings")
	for prop: String in PROPERTIES:
		set(prop, settings.get(prop))
		
