@tool
class_name Messager extends CanvasLayer
const GRAYSCALE_MATERIAL: ShaderMaterial = preload("res://scenes/messager/grayscale_material.tres")
const ENVIRONMENT : Environment = preload("res://resources/environment/environment.tres")

var tw: Tween 

func _ready() -> void:
	if Engine.is_editor_hint(): return
	hide_all()
	if get_tree().current_scene is Level: 
		connect_scene(get_tree().current_scene)
	
	get_tree().root.child_entered_tree.connect(_on_root_child_entered_tree)

func connect_scene(level: Level) -> void:
	level.goal_reached.connect(_on_goal_reached)
	level.player_dead.connect(_on_player_dead)


func show_message(msg: String) -> void:
	const FADE_IN_TIME: float = 0.5
	show()
	%MainLabel.text = msg
	tw = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	tw.tween_method(ENVIRONMENT.set_adjustment_saturation , 1.0, 0.0, FADE_IN_TIME)
	tw.set_parallel().tween_property(%Rect, ^"modulate:a", 1.0, FADE_IN_TIME)
	tw.chain().tween_property(%MainLabel, ^"modulate:a", 1.0, FADE_IN_TIME).from(0.0)
	tw.tween_property(%CornerLabel, ^"modulate:a", 1.0, FADE_IN_TIME).from(0.0)


func _on_player_dead(collider: Node) -> void:
	show_message("You died")


func hide_all() -> void:
	hide()
	if tw and tw.is_valid():
		tw.kill()
	%MainLabel.modulate.a = 0.0
	%SubLabel.modulate.a = 0.0
	%CornerLabel.modulate.a = 0.0
	ENVIRONMENT.set_adjustment_saturation(1.0)
	%Rect.modulate.a = 0.0

func show_level_clear_message() -> void:
	show_message("Level Clear")
func _on_goal_reached() -> void:
	show_message.bind("Level Clear")
	

func _on_root_child_entered_tree(node: Node) -> void:
	if node is Level: 
		hide_all()
		connect_scene(node)
