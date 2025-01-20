@icon("res://assets/textures/ClassIcons16x16/camera_edit.png")
@tool
class_name ControllerAttributes extends Resource

signal pivot_distance_changed
signal pitch_changed(new_pitch: float)
signal roll_changed(new_roll: float)

##
@export var distance_from_pivot: float = 3.0:
	set(value):
		distance_from_pivot = value
		pivot_distance_changed.emit()
		emit_changed()

@export var camera_y_offset: float = 0.5

##
@export_range(-90.0, 90.0) var initial_dive_angle_deg: float = -30.0:
	set(value):
		initial_dive_angle_deg = value
		pitch_changed.emit()
		emit_changed()

##
@export_range(0.0, 40.0, 0.5) var pitch_limit_deg: float = 35.0

##
@export_range(0.0, 40.0) var roll_limit_deg: float = 30.0

##
@export_range(40.0, 1000.0, 0.5, "or_less", "or_greater") var tilt_speed: float = 202.0

##
@export_range(1.0, 1000.0) var horizontal_rotation_sensitiveness: float = 10.0


## Additional pitch to add to [initial_dive_angle_deg]
@export_custom(0, "", PROPERTY_USAGE_EDITOR) var pitch: float = 0.0:
	set(val):
		pitch = val
		pitch_changed.emit()
		emit_changed()

##
@export_custom(0, "", PROPERTY_USAGE_EDITOR) var roll: float = 0.0:
	set(val):
		roll = clampf(val, -roll_limit_deg, roll_limit_deg)
		roll_changed.emit(roll)
		emit_changed()


var yaw: float = 0.0
