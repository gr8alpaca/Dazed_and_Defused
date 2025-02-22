@tool
extends Control

const INPUT_TEXTURES: InputTextures = preload("res://resources/input_textures.tres")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	INPUT_TEXTURES.changed.connect(update_input_texture)
	Audio.pause_music()
	update_input_texture()
	animate_end()

func animate_end() -> void:
	%Corner.modulate.a = 0.0
	%End.visible_ratio = 0.0
	%Hugo.visible_ratio = 0.0
	
	const INITIAL_DELAY_SEC: float = 1.5
	const SEGMENT_DELAY_SEC: float = 1.0
	const END_DURATION_SEC: float = 2.0
	const PROMPT_FADE_DURATION_SEC: float = 1.2
	
	var tw: Tween = create_tween()
	tw.tween_interval(INITIAL_DELAY_SEC)
	tw.tween_property(%End, ^"visible_ratio", 1.0, END_DURATION_SEC)
	tw.tween_interval(SEGMENT_DELAY_SEC)
	tw.tween_property(%Hugo, ^"visible_ratio", 0.85, END_DURATION_SEC)
	tw.tween_interval(0.5)
	tw.tween_property(%Hugo, ^"visible_ratio", 1.0, 2.0)
	tw.tween_interval(SEGMENT_DELAY_SEC)
	tw.tween_property(%Corner, ^"modulate:a", 1.0, PROMPT_FADE_DURATION_SEC)
	await tw.finished
	tw = create_tween().set_loops(0)
	tw.tween_property(%Corner, ^"modulate:a", 0.0, PROMPT_FADE_DURATION_SEC)
	tw.tween_property(%Corner, ^"modulate:a", 1.0, PROMPT_FADE_DURATION_SEC)

func update_input_texture() -> void:
	%ButtonTexture.texture = INPUT_TEXTURES.get_texture(&"ui_cancel") 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		var tw: Tween = create_tween()
		tw.tween_property(%Overlay, ^"modulate:a", 0.0, 1.0)
		tw.tween_callback(Master.reset_to_main)
		#Master.reset_to_main()
