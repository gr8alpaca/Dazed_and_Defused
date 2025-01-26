@icon("res://assets/textures/ClassIcons16x16/object.png")
@tool
class_name Obstacle extends AnimatableBody3D

@export_tool_button("Test Tween", &"Tween")
var execute: Callable = start

@export_placeholder("rotation:y") var property_path: String
@export var start_val: float = 0.0
@export var end_val: float = 1.0
@export_range(0.001, 5.0, 0.05, "or_greater", "suffix:s") var duration_sec: float = 1.0
@export var tween_both_ways: bool = false

@export var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var tween_trans: Tween.TransitionType = Tween.TRANS_LINEAR

var dict: Dictionary[String, Dictionary]
var tween: Tween

var cushion: float = 1.0:
	set(val):
		cushion = val
		set_meta(&"cushion", val)


func _ready() -> void:
	if not Engine.is_editor_hint():
		start()


func start() -> void:
	if not tween or not tween.is_valid():
		tween = create_tween().set_ease(tween_ease).set_trans(tween_trans).set_loops(int(Engine.is_editor_hint()))
		tween.tween_property(self, property_path, end_val, duration_sec).from(start_val)
		if tween_both_ways:
			tween.tween_property(self, property_path, start_val, duration_sec).from(end_val)
		return
	
	tween.play()


func pause() -> void:
	if tween and tween.is_running(): 
		tween.pause()

func stop() -> void:
	if tween and tween.is_valid(): 
		tween.kill()
