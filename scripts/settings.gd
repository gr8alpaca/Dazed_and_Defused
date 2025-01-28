@icon("res://assets/textures/ClassIcons16x16/settings_save.png")
@tool
class_name Settings extends Resource # "movement_sensitivity",
const PROPERTIES: PackedStringArray = [ "movment_deadzone", "camera_sensitivity", "camera_deadzone", "sfx_volume", "music_volume",]

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

@export_range(1.0, 100.0, 1.0, "suffix:%")
var sfx_volume: float = 100.0:
	set(val):
		sfx_volume = val
		linear_to_db(val/100.0)

@export_range(1.0, 100.0, 1.0, "suffix:%") 
var music_volume: float = 100.0:
	set(val):
		music_volume = val
		linear_to_db(val/100.0)

func SET(property: StringName, value: Variant) -> void:
	set(property, value)


#endregion
