@tool
class_name Messager extends CanvasLayer

const INPUT_TEXTURES: InputTextures = preload("res://resources/input_textures.tres")
const ENVIRONMENT : Environment = preload("res://resources/environment/environment.tres")

const FADE_IN_TIME: float = 0.5

var tw: Tween 

func _ready() -> void:
	if Engine.is_editor_hint(): return
	%Reset.hide()
	hide_all.call_deferred()
	if get_tree().current_scene is Level: 
		connect_scene(get_tree().current_scene)
	
	get_tree().root.child_entered_tree.connect(_on_root_child_entered_tree)
	INPUT_TEXTURES.changed.connect(update_input_device)

func connect_scene(level: Level) -> void:
	level.goal_reached.connect(_on_goal_reached)
	level.player_dead.connect(_on_player_dead)

func show_message(msg: String, label_fade_time_sec: float = FADE_IN_TIME) -> void:
	show()
	%MainLabel.text = msg
	if tw and tw.is_valid():
		tw.kill()
	tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tw.tween_method(ENVIRONMENT.set_adjustment_saturation , 1.0, 0.0, FADE_IN_TIME)
	tw.set_parallel().tween_property(%Rect, ^"modulate:a", 1.0, FADE_IN_TIME).from(0.0)
	tw.chain().tween_property(%MainLabel, ^"modulate:a", 1.0, FADE_IN_TIME)
	tw.tween_property(%Corner, ^"modulate:a", 1.0, FADE_IN_TIME).from(0.0)


func hide_all() -> void:
	hide()
	if tw and tw.is_valid():
		tw.kill()
	
	%MainLabel.modulate.a = 0.0
	%SubLabel.modulate.a = 0.0
	%Corner.modulate.a = 0.0
	tw = create_tween()
	tw.tween_method(ENVIRONMENT.set_adjustment_saturation , 1.0, 1.0, FADE_IN_TIME)
	%Rect.modulate.a = 0.0

func update_input_device() -> void:
	%ButtonTexture.texture = INPUT_TEXTURES.get_texture(&"reset")

func _on_goal_reached() -> void:
	%MainLabel.text = "Defused"
	%MainLabel.modulate.a = 1.0
	show_message("Defused", 0.0)

func _on_player_dead(collider: Node) -> void:
	show_message("You died")

func _on_root_child_entered_tree(node: Node) -> void:
	if get_tree().current_scene == node:
		hide_all()
	
	if node is Level:
		connect_scene(node)
