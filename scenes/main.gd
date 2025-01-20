class_name Main extends Node3D

const LEVEL_DIR: String = "res://scenes/levels/"

var current_level: int = 0

func set_level_index(level_index: int) -> void:
	var current_level: Level = get_current_level()
	if current_level:
		remove_child(current_level)
		current_level.free()
	
	var level : Level = load(get_level_path(level_index)).instantiate()
	add_child(level)

func get_level_path(idx: int) -> String:
	var level_paths:= DirAccess.get_files_at(LEVEL_DIR)
	return level_paths[clampi(idx, 0, level_paths.size() - 1)]

func next_level() -> void:
	pass

func get_current_level() -> Level:
	for child in get_children():
		if child is Level: return child
	return null

func reset_level() -> void:
	get_tree().reload_current_scene()
