@tool
class_name Messager extends CanvasLayer
const GRAYSCALE_MATERIAL: ShaderMaterial = preload("res://scenes/messager/grayscale_material.tres")
const ENVIRONMENT : Environment = preload("res://resources/environment/environment.tres")
const INPUT_TEXTURES:= [
	#KEYBOARD
	{
		reset = preload("res://assets/textures/buttons/keyboard/R_Key_Dark.png"),
	},
	#XBOX
	{
		reset = preload("res://assets/textures/buttons/xbox/XboxSeriesX_Y.png"),
	},
	#PLAYSTATION
	{
		reset = preload("res://assets/textures/buttons/ps/PS5_Triangle.png")
	},
]

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

const FADE_IN_TIME: float = 0.5
func show_message(msg: String, label_fade_time_sec: float = FADE_IN_TIME) -> void:
	
	show()
	%MainLabel.text = msg
	if tw and tw.is_valid():
		tw.kill()
	tw = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	tw.tween_method(ENVIRONMENT.set_adjustment_saturation , 1.0, 0.0, FADE_IN_TIME)
	tw.set_parallel().tween_property(%Rect, ^"modulate:a", 1.0, FADE_IN_TIME)
	tw.chain().tween_property(%MainLabel, ^"modulate:a", 1.0, label_fade_time_sec).from(0.0)
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

func update_input_device(type: int) -> void:
	%ButtonTexture.texture = INPUT_TEXTURES[type].reset
	

func _on_goal_reached() -> void:
	show_message("Level Clear", 0.1)

func _on_player_dead(collider: Node) -> void:
	show_message("You died")

func _on_root_child_entered_tree(node: Node) -> void:
	if node is Level: 
		hide_all()
		connect_scene(node)
