@tool
class_name TrapAction extends Resource

@export_node_path var target_node_path: NodePath
@export var path: String
@export_range(0.0, 5.0, 0.05, "or_greater", "suffix:s") 
var additional_delay_sec: float = 0.0
@export_range(0.001, 5.0, 0.05, "or_greater", "suffix:s") 
var reset_speed_sec: float = 1.0

@export var arguments: Array

var is_running: bool = false

func execute(host_node: Node) -> Tween:
	print("Calling %s from host node %s" % [path, host_node.name])
	var callable:= Callable(host_node.get_node(target_node_path), path)
	assert(callable.is_valid(), "Callable is invalid")
	is_running = true
	
	var tw: Tween = host_node.create_tween()
	tw.tween_interval(additional_delay_sec)
	tw.tween_callback(callable if arguments.is_empty() else callable.bindv(arguments))
	tw.tween_interval(reset_speed_sec)
	tw.tween_callback(set.bind(&"is_running", false))
	return tw
