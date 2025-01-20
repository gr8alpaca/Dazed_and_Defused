@tool
class_name Messager extends CanvasLayer


func _ready() -> void:
	if Engine.is_editor_hint(): return
	hide_all()
	connect_scene(get_tree().current_scene)
	get_tree().root.child_entered_tree.connect(_on_root_child_entered_tree)

func connect_scene(level: Level) -> void:
	if not level.is_node_ready():
		await level.ready
	level.goal_reached.connect(show_message.bind("Level Clear"))
	var player: Player = get_tree().get_first_node_in_group(Player.GROUP)
	
	player.dead.connect(_on_dead)


func show_message(msg: String) -> void:
	const FADE_IN_TIME: float = 0.5
	show()
	%MainLabel.text = msg
	#%CornerLabel.text = "R to reset"
	var tw: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	tw.tween_property(%MainLabel, ^"modulate:a", 1.0, FADE_IN_TIME).from(0.0)
	tw.tween_property(%CornerLabel, ^"modulate:a", 1.0, FADE_IN_TIME).from(0.0)


func _on_dead(collider: Node) -> void:
	show_message("You died")


func hide_all() -> void:
	hide()
	%MainLabel.modulate.a = 0.0
	%SubLabel.modulate.a = 0.0
	%CornerLabel.modulate.a = 0.0

func _on_root_child_entered_tree(node: Node) -> void:
	if node is Level: 
		hide_all()
		connect_scene(node)
