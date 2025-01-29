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

@export var camera_shake: bool = true
@export var is_first_load: bool

var is_loaded: bool = false

func save_settings() -> void:
	ResourceSaver.save(duplicate(), PATH, ResourceSaver.FLAG_CHANGE_PATH)

func load_settings() -> void:
	if Engine.is_editor_hint(): return
	is_loaded = true
	if not ResourceLoader.exists(PATH, "Settings"): 
		print("Settings resource does not exist...")
		return
	print("Settings loading...")
	var settings: Settings = ResourceLoader.load(PATH, "Settings")
	for prop: String in PROPERTIES:
		set(prop, settings.get(prop))

func reset_to_default() -> void:
	var script: Script = get_script()
	for dict: Dictionary in script.get_script_property_list():
		set(dict.name, script.get_property_default_value(dict.name))
		#print("resetting %s to value %s" % [prop, script.get_property_default_value(prop)])

func get_movement_sensitivity() -> float:
	return movement_sensitivity
func get_movement_deadzone() -> float:
	return movment_deadzone
func get_camera_sensitivity() -> float:
	return camera_sensitivity
func get_camera_deadzone() -> float:
	return camera_deadzone
func get_camera_shake() -> bool:
	return camera_shake
