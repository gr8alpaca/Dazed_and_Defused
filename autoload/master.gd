extends Node

var messager: Messager
var transitioner: Transitioner

var current_level: int = 1

func _ready() -> void:
	if Engine.is_editor_hint(): return
	messager = load("res://scenes/messager/messager.tscn").instantiate()
	transitioner = load("res://scenes/transitioner/transitioner.tscn").instantiate()
	transitioner.reset()
	
	var root: Window = get_tree().root
	if not root.is_node_ready():
		await root.ready
	
	root.add_child.call_deferred(messager)
	root.add_child.call_deferred(transitioner)

func change_level(level_number: int) -> void:
	var level_path: String = "res://scenes/levels/%d.tscn" % level_number
	print("Transitioning to level #%d" % level_number)
	if ResourceLoader.exists(level_path, "PackedScene"):
		transitioner.transition(level_path)
		current_level = level_number
	elif level_number == 1:
		print("Level Scene \"%s\" not found, defaulting to main scene..." % level_path)
		transitioner.transition(ProjectSettings.get_setting("application/run/main_scene"))
	else:
		change_level(1)


func reset_level() -> void:
	get_tree().reload_current_scene()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_pressed(): return
	
	if event.is_action_pressed(&"reset"):
		reset_level()
	elif Input.is_key_pressed(KEY_1):
		change_level(1)
	elif Input.is_key_pressed(KEY_2):
		change_level(2)
	elif Input.is_key_pressed(KEY_3):
		change_level(3)
	else:
		return
	
	get_viewport().set_input_as_handled()
