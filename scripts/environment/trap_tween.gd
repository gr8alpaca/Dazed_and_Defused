@tool
class_name TrapTween extends TrapAction

@export var start_value: float = 0.0
@export var end_value: float = 1.0

@export_range(0.001, 5.0, 0.05, "or_greater", "suffix:s") 
var action_speed_sec: float = 1.0

@export_range(0.001, 5.0, 0.05, "or_greater", "suffix:s") 
var idle_duration_sec: float = 0.0


@export_group("Ease & Trans")
@export var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var tween_trans: Tween.TransitionType = Tween.TRANS_LINEAR


func execute(host_node: Node) -> Tween:
	assert(host_node.has_node(target_node_path), "Invalid target node")
	is_running = true
	var body: Node = host_node.get_node(target_node_path)
	var tw: Tween = host_node.create_tween().set_trans(tween_trans).set_ease(tween_ease)
	tw.tween_property(body, path, end_value, action_speed_sec)
	tw.tween_interval(idle_duration_sec)
	tw.tween_property(body, path, start_value, reset_speed_sec)
	tw.tween_callback(set.bind(&"is_running", false))
	return tw

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"arguments": property.usage &= ~(PROPERTY_USAGE_EDITOR)
