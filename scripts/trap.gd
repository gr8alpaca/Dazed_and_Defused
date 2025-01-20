@tool
class_name Trap extends Node3D

@export_tool_button("Test Trap", "AnimatableBody3D")
var trigger_trap_function: Callable = trigger

@export var area_trigger: Area3D: set = set_area_trigger

@export var body: AnimatableBody3D
@export var body_property: String = "position:x"
@export var start_value: float = 0.0
@export var end_value: float = 1.0

@export var tween_trans: Tween.TransitionType = Tween.TRANS_LINEAR

@export_range(0.001, 10.0, 0.05, "suffix:s") var trigger_speed_sec: float = 0.5
@export_range(0.001, 10.0, 0.05, "suffix:s") var idle_duration_sec: float = 0.0
@export_range(0.01, 20.0, 0.2, "suffix:s") var reset_speed_sec: float = 2.0

var triggered: bool = false : set = set_triggered


func _on_trigger(body: Node) -> void:
	set_triggered(true)

func trigger() -> void:
	assert(body != null, "No body set!")
	var tw: Tween = create_tween().set_trans(tween_trans)
	tw.tween_property(body, body_property, end_value, trigger_speed_sec)
	tw.tween_interval(idle_duration_sec)
	tw.tween_property(body, body_property, start_value, reset_speed_sec)
	tw.tween_callback(set_triggered.bind(false))


func set_triggered(val: bool) -> void:
	if triggered == val: return
	if not triggered and val: 
		trigger()
	triggered = val


func set_area_trigger(val: Area3D) -> void:
	if not Engine.is_editor_hint() and area_trigger and area_trigger.body_entered.is_connected(_on_trigger):
		area_trigger.body_entered.disconnect(_on_trigger)
	
	area_trigger = val
	
	if area_trigger and not area_trigger.body_entered.is_connected(_on_trigger):
		area_trigger.body_entered.connect(_on_trigger)
