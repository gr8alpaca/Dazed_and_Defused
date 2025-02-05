@icon("res://assets/textures/ClassIcons16x16/world.png")
@tool
class_name Level extends Node3D

signal player_dead(collider: Node)
signal goal_reached
#
#@export var level_name: String = ""
var pause_menu: PauseMenu

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Audio.play_music(Audio.MUSIC_LIBRARY.main_theme)
	for goal: Goal in find_children("*", "Goal"):
		goal.body_entered.connect(_on_goal_entered.bind(goal), CONNECT_ONE_SHOT)
	
	var player: Player = find_child("Player")
	assert(player, "No player instance set for level %s" % name)
	if not player:
		player = load(Player.SCENE_PATH).instantiate()
		add_child(player)
	player.dead.connect(_on_dead)
	
	var label: Label = Label.new()
	add_child(label)
	label.modulate.a = 0.0
	label.text = "%d - %s" % [Master.current_level, name]
	label.set_offsets_preset(Control.PRESET_BOTTOM_LEFT,Control.PRESET_MODE_MINSIZE, 16)

	const DELAY_SEC: float = 1.0
	const FADE_DURATION_SEC: float = 0.7
	const LABEL_DURATION_SEC: float = 3.0
	var tw: Tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tw.tween_interval(DELAY_SEC)
	tw.tween_property(label, ^"modulate:a", 1.0, FADE_DURATION_SEC)
	tw.tween_interval(LABEL_DURATION_SEC)
	tw.tween_property(label, ^"modulate:a", 0.0, FADE_DURATION_SEC)
	tw.tween_callback(label.queue_free)
	pause_menu = PauseMenu.new()
	add_child(pause_menu)


func _on_dead(collider: Node) -> void:
	pause_menu.set_process_input(false)
	player_dead.emit(collider)

func _on_goal_entered(player: Node3D, goal: Goal) -> void:
	pause_menu.set_process_input(false)
	player.set_collision_sensor_enabled(false)
	player.input_active = false
	player.linear_damp = 10.0
	player.defuse()
	goal_reached.emit()
	Master.change_level.call_deferred(Master.current_level + 1)
