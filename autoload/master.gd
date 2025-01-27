extends Node

const LEVEL_PATHS:PackedStringArray = [
	"res://scenes/levels/basic.tscn",
	"res://scenes/levels/tightrope.tscn",
	"res://scenes/levels/bridge.tscn",
	"res://scenes/levels/pipe.tscn",
	"res://scenes/levels/platforms.tscn",
	"res://scenes/levels/turbine.tscn",
	"res://scenes/levels/traffic_light.tscn",
	
	# End Scene Here...
	"res://scenes/menus/end/end.tscn",
]

var messager: Messager
var transitioner: Transitioner

var current_level: int = 1

func _ready() -> void:
	
	for path: String in LEVEL_PATHS:
		if ResourceLoader.exists(path, "PackedScene"): continue
		push_warning("Level path '%s' does not exist..." % path)
	
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
	var level_path: String = LEVEL_PATHS[clampi(level_number-1, 0, LEVEL_PATHS.size()-1)]
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

func get_current_level() -> int:
	return LEVEL_PATHS.find(get_tree().current_scene.scene_file_path) + 1

func reset_to_main() -> void:
	transitioner.transition(ProjectSettings.get_setting("application/run/main_scene"))
	current_level = 1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_pressed(): return
	
	if event.is_action_pressed(&"reset"):
		reset_level()
	elif Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_1):
		change_level(1)
	elif Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_2):
		change_level(2)
	elif Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_3):
		change_level(3)
	elif Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_4):
		change_level(4)
	elif Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_5):
		change_level(5)
	elif Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_6):
		change_level(6)
	elif Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_RIGHT):
		change_level(7)
	elif Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_END):
		change_level(LEVEL_PATHS.size())
	
	else:
		return
	
	get_viewport().set_input_as_handled()
