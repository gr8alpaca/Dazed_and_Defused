extends Node

const LEVEL_DIR: String = "res://scenes/levels/"

var current_level: int = 1
var transitioner: Transitioner


func _ready() -> void:
	if Engine.is_editor_hint(): return
	var messager: Messager = load("res://scenes/messager/messager.tscn").instantiate()
	
	transitioner = load("res://scenes/transitioner/transitioner.tscn").instantiate()
	transitioner.reset()
	
	var root: Window = get_tree().root
	if not root.is_node_ready():
		await root.ready
	root.add_child.call_deferred(messager)
	root.add_child.call_deferred(transitioner)
	
func change_level(level_number: int) -> void:
	transitioner.transition(LEVEL_DIR.path_join(str(level_number if level_number < 3 else 1) + ".tscn"))

func reset_level() -> void:
	get_tree().reload_current_scene()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_pressed(): return
	
	if Input.is_key_pressed(KEY_R):
		reset_level()
	elif Input.is_key_pressed(KEY_1) and Input.is_key_pressed(KEY_SHIFT):
		change_level(1)
	elif Input.is_key_pressed(KEY_2) and Input.is_key_pressed(KEY_SHIFT):
		change_level(2)
		#change_level("res://scenes/levels/2.tscn")
		#"res://scenes/levels/2.tscn"
