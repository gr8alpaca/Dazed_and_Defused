extends Node

const LEVEL_DIR: String = "res://scenes/levels/"

var current_level: int = 1

func _ready() -> void:
	if Engine.is_editor_hint(): return
	var messager: Messager = load("res://scenes/messager/messager.tscn").instantiate()
	var root: Window = get_tree().root
	if not root.is_node_ready():
		await root.ready
	get_tree().root.add_child.call_deferred(messager)

func change_level(idx: int) -> void:
	pass
	get_tree().current_scene


func reset_level() -> void:
	get_tree().reload_current_scene()
	

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_R):
		reset_level()
