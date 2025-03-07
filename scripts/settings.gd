@icon("res://assets/textures/ClassIcons16x16/settings_save.png")
@tool
class_name Settings extends Resource

const PATH: String = "user://settings.tres"

const PROPERTIES: PackedStringArray = ["movement_sensitivity", "movment_deadzone", "joystick_hud_size", "camera_sensitivity", "camera_deadzone",  "sfx_volume", "music_volume", "skybox_move_speed", ]

signal volume_changed(bus: int, value: float)

@export_range(0.1, 15.0, 0.1, "exp")
var movement_sensitivity: float = 3.0

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


@export_range(0.0, 100.0, 1.0, "suffix:%")
var sfx_volume: float = 50.0:
	set(val):
		sfx_volume = val
		volume_changed.emit(Audio.BUS_SFX, get_sfx_volume())

@export_range(0.0, 100.0, 1.0, "suffix:%") 
var music_volume: float = 10.0:
	set(val):
		music_volume = val
		volume_changed.emit(Audio.BUS_MUSIC, get_music_volume())
@export_range(0.0, 100.0, 5.0, )
var skybox_move_speed: float = 20.0:
	set(val):
		skybox_move_speed = val
		RenderingServer.global_shader_parameter_set(&"speed", val)

@export_range(32, 512, 1, "suffix:px")
var joystick_hud_size: int = 128:
	set(val):
		joystick_hud_size = val
		ThemeDB.get_project_theme().set_constant(&"hud_size", &"VirtualJoystick", joystick_hud_size)

@export var camera_shake: bool = true

var loaded: bool = false

func save_settings() -> void:
	var new_settings: Settings = duplicate()
	new_settings.take_over_path(PATH)
	ResourceSaver.save(new_settings, PATH, ResourceSaver.FLAG_CHANGE_PATH)

func load_settings() -> void:
	if Engine.is_editor_hint(): return
	
	loaded = true
	
	if not ResourceLoader.exists(PATH, "Settings"): 
		printerr("Settings resource does not exist...")
		return
	
	var settings: Settings = ResourceLoader.load(PATH, "Settings")
	for prop: String in PROPERTIES:
		set(prop, settings.get(prop))

func reset_to_default() -> void:
	var script: Script = get_script()
	for prop: StringName in PROPERTIES:
		set(prop, script.get_property_default_value(prop))
		#print("resetting %s to value %s" % [prop, script.get_property_default_value(prop)])

func get_sfx_volume() -> float:
	return sfx_volume
func get_music_volume() -> float:
	return music_volume
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
func is_loaded() -> bool:
	return loaded
