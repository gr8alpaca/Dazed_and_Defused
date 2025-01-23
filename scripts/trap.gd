@icon("res://assets/textures/ClassIcons16x16/laser.png")
@tool
class_name Trap extends Node3D

@export_tool_button("Test Trap", "AnimatableBody3D")
var trigger_trap_function: Callable = trigger

@export var disabled: bool = false
@export var area_trigger: Area3D: set = set_area_trigger
#
#@export var body: AnimatableBody3D
#@export var body_property: String = "position:x"
#@export var start_value: float = 0.0
#@export var end_value: float = 1.0

#@export var tween_trans: Tween.TransitionType = Tween.TRANS_LINEAR

@export_range(0.001, 10.0, 0.05, "or_greater", "suffix:s",) var delay_sec: float = 0.0
#@export_range(0.001, 10.0, 0.05, "or_greater", "suffix:s", ) var trigger_speed_sec: float = 0.5
#@export_range(0.001, 10.0, 0.05, "or_greater", "suffix:s",) var idle_duration_sec: float = 0.0
#@export_range(0.001, 20.0, 0.2, "or_greater", "suffix:s",) var reset_speed_sec: float = 2.0
@export var cancel_on_player_exit: bool = false

@export var actions: Array[TrapAction]

var triggered: bool = false


func disable() -> void:
	disabled = true
func enable() -> void:
	if not disabled: return
	disabled = false
	if area_trigger.has_overlapping_bodies():
		attempt_trigger()


func attempt_trigger() -> void:
	if triggered or disabled: return
	trigger()


func trigger() -> void:
	triggered = true
	for act: TrapAction in actions:
		if not act: continue
		act.execute(self).tween_callback(_on_action_finished)


func _on_action_finished() -> void:
	if actions.any(is_action_running): return
	triggered = false

func is_action_running(action: TrapAction) -> bool:
	return action.is_running if action else false

func _on_trigger(body: Node) -> void:
	if triggered or disabled: return
	var tw: Tween = create_tween()
	tw.tween_callback(attempt_trigger).set_delay(delay_sec)
	if cancel_on_player_exit:
		area_trigger.body_exited.connect(tw.kill.unbind(1))


func set_area_trigger(val: Area3D) -> void:
	if not Engine.is_editor_hint() and area_trigger and area_trigger.body_entered.is_connected(_on_trigger):
		area_trigger.body_entered.disconnect(_on_trigger)
	area_trigger = val
	if area_trigger and not area_trigger.body_entered.is_connected(_on_trigger):
		area_trigger.body_entered.connect(_on_trigger)
	
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	return ["No area trigger set"] if not area_trigger else []
