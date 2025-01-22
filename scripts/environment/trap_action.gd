@tool
class_name TrapAction extends Resource

@export_node_path var target_node: NodePath
@export var path: String
var is_running: bool = false

func set_running(val: bool) -> void:
	is_running = val

func execute(host_node: Node) -> Tween:
	#is_running = true
	var body:= host_node.get_node(target_node)
	var tw: Tween = host_node.create_tween()
	tw.tween_callback(Callable(body, path))
	#is_running = false
	return tw
